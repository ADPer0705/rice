#!/usr/bin/env bash
# shellcheck shell=bash
# home.sh - copy configs between $HOME and the repo, and report drift.

DRY_RUN="${DRY_RUN:-0}"

# NTFS/FUSE cannot represent POSIX ownership or modes reliably. Compare and
# copy content only; file modes are handled by git's index and .gitattributes.
RICE_RSYNC_FLAGS=(--no-perms --no-owner --no-group)

# Locate the newest Zen profile directory. Returns an empty string when Zen
# has never been launched; in that case deploy tells the user to launch it once.
resolve_zen_profile() {
    local zen="$HOME/.zen"
    [[ -d "$zen" ]] || { printf '\n'; return 0; }
    local latest=""
    latest="$(find "$zen" -maxdepth 1 -mindepth 1 -type d -name '*Default*' \
        ! -name 'profile' -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | head -1 | cut -d' ' -f2- || true)"
    printf '%s\n' "$latest"
}

_zen_dest() {
    local fallback="$HOME/.zen/profile"
    local profile
    profile="$(resolve_zen_profile)"
    if [[ -n "$profile" ]]; then
        printf '%s\n' "$profile"
    else
        printf '%s\n' "$fallback"
    fi
}

_deploy_file() {
    local src="$1" dest="$2" flags="${3:-}"
    if [[ ! -f "$src" ]]; then
        warn "missing in repo: ${src#"$RICE_REPO"/}"
        return 0
    fi
    if [[ -f "$dest" ]] && same_file "$src" "$dest"; then
        return 0
    fi
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would copy ${src#"$RICE_REPO"/} -> $dest"
        return 0
    fi
    mkdir -p "$(dirname "$dest")"
    backup_target "$dest"
    cp -a "$src" "$dest"
    [[ ",$flags," == *",exec,"* ]] && chmod 0755 "$dest"
    ok "deployed $dest"
}

_deploy_dir() {
    local src="$1" dest="$2" flags="$3"
    local -a opts=(-a "${RICE_RSYNC_FLAGS[@]}")
    [[ ",$flags," == *",delete,"* ]] && opts+=(--delete)
    if [[ ! -d "$src" ]]; then
        warn "missing in repo: ${src#"$RICE_REPO"/}"
        return 0
    fi
    if rsync_is_clean "${opts[@]}" "$src/" "$dest/"; then
        return 0
    fi
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would sync ${src#"$RICE_REPO"/}/ -> $dest/"
        return 0
    fi
    mkdir -p "$dest"
    backup_target "$dest"
    rsync "${opts[@]}" "$src/" "$dest/"
    ok "deployed $dest/"
}

_deploy_zen() {
    local src="$1"
    local profile
    profile="$(resolve_zen_profile)"
    if [[ -z "$profile" ]]; then
        warn "no Zen profile found; launch Zen once, then re-run deploy"
        return 0
    fi
    local rel
    for rel in "${RICE_ZEN_FILES[@]}"; do
        [[ -f "$src/$rel" ]] || continue
        _deploy_file "$src/$rel" "$profile/$rel"
    done
}

deploy_home() {
    ensure_state
    info "deploying configs into $HOME"
    local entry type src dest flags
    for entry in "${RICE_MANIFEST[@]}"; do
        IFS='|' read -r type src dest flags <<<"$entry"
        src="$RICE_REPO/$src"
        dest="$HOME/$dest"
        case "$type" in
            file) _deploy_file "$src" "$dest" "$flags" ;;
            dir)  _deploy_dir "$src" "$dest" "$flags" ;;
            zen)
                if [[ -z "$(resolve_zen_profile)" ]]; then
                    _deploy_zen "$src"
                else
                    _deploy_zen "$src"
                fi
                ;;
            *) warn "unknown manifest type: $type" ;;
        esac
    done
    if [[ "$DRY_RUN" == 0 ]] && have fc-cache; then
        fc-cache -f >/dev/null 2>&1 || true
        ok "font cache refreshed"
    fi
    info "deploy complete"
}

_sync_file() {
    local src="$1" dest="$2"
    if [[ ! -f "$dest" ]]; then
        warn "not present on this machine: $dest"
        return 0
    fi
    if [[ -f "$src" ]] && same_file "$src" "$dest"; then
        return 0
    fi
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would capture $dest -> ${src#"$RICE_REPO"/}"
        return 0
    fi
    mkdir -p "$(dirname "$src")"
    cp -a "$dest" "$src"
    [[ -x "$dest" ]] && chmod 0755 "$src" 2>/dev/null || true
    ok "captured $dest"
}

_sync_dir() {
    local src="$1" dest="$2" flags="$3"
    if [[ ! -d "$dest" ]]; then
        warn "not present on this machine: $dest"
        return 0
    fi
    local -a opts=(-a "${RICE_RSYNC_FLAGS[@]}" --exclude=.git/ --exclude='*.log' --exclude='*.swp' --exclude='*~')
    [[ ",$flags," == *",delete,"* ]] && opts+=(--delete)
    if rsync_is_clean "${opts[@]}" "$dest/" "$src/"; then
        return 0
    fi
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would capture $dest/ -> ${src#"$RICE_REPO"/}/"
        return 0
    fi
    mkdir -p "$src"
    rsync "${opts[@]}" "$dest/" "$src/"
    ok "captured $dest/"
}

_sync_zen() {
    local src="$1"
    local profile
    profile="$(resolve_zen_profile)"
    if [[ -z "$profile" ]]; then
        warn "no Zen profile found; skipping"
        return 0
    fi
    local rel
    for rel in "${RICE_ZEN_FILES[@]}"; do
        [[ -f "$profile/$rel" ]] || continue
        _sync_file "$src/$rel" "$profile/$rel"
    done
}

sync_home() {
    ensure_state
    info "capturing configs from $HOME"
    local entry type src dest flags
    for entry in "${RICE_MANIFEST[@]}"; do
        IFS='|' read -r type src dest flags <<<"$entry"
        src="$RICE_REPO/$src"
        dest="$HOME/$dest"
        case "$type" in
            file) _sync_file "$src" "$dest" ;;
            dir)  _sync_dir "$src" "$dest" "$flags" ;;
            zen)  _sync_zen "$src" ;;
            *) warn "unknown manifest type: $type" ;;
        esac
    done
    info "capture complete"
}

_status_one() {
    local label="$1" clean="$2"
    if [[ "$clean" == 1 ]]; then
        printf '%s ok %s %-52s %s\n' "$C_GREEN" "$C_RESET" "$label" "in sync"
        return 0
    fi
    printf '%s!!%s %-52s %s\n' "$C_YELLOW" "$C_RESET" "$label" "drift"
    return 1
}

status_home() {
    local drift=0
    local entry type src dest flags
    for entry in "${RICE_MANIFEST[@]}"; do
        IFS='|' read -r type src dest flags <<<"$entry"
        src="$RICE_REPO/$src"
        dest="$HOME/$dest"
        case "$type" in
            file)
                if [[ -f "$src" && -f "$dest" ]] && same_file "$src" "$dest"; then
                    _status_one "$dest" 1 || drift=$((drift + 1))
                else
                    _status_one "$dest" 0 || drift=$((drift + 1))
                fi
                ;;
            dir)
                local -a opts=(-a "${RICE_RSYNC_FLAGS[@]}")
                [[ ",$flags," == *",delete,"* ]] && opts+=(--delete)
                if [[ -d "$src" && -d "$dest" ]] && rsync_is_clean "${opts[@]}" "$src/" "$dest/"; then
                    _status_one "$dest/" 1 || drift=$((drift + 1))
                else
                    _status_one "$dest/" 0 || drift=$((drift + 1))
                fi
                ;;
            zen)
                local profile rel clean=1
                profile="$(resolve_zen_profile)"
                if [[ -z "$profile" ]]; then
                    _status_one "Zen profile" 0 || drift=$((drift + 1))
                    continue
                fi
                for rel in "${RICE_ZEN_FILES[@]}"; do
                    [[ -f "$src/$rel" ]] || continue
                    if [[ ! -f "$profile/$rel" ]] || ! same_file "$src/$rel" "$profile/$rel"; then
                        clean=0
                    fi
                done
                _status_one "Zen ($profile)" "$clean" || drift=$((drift + 1))
                ;;
        esac
    done
    if [[ "$drift" -gt 0 ]]; then
        err "$drift path(s) differ between repo and $HOME"
        return 1
    fi
    ok "all paths in sync"
    return 0
}

diff_home() {
    local entry type src dest flags
    for entry in "${RICE_MANIFEST[@]}"; do
        IFS='|' read -r type src dest flags <<<"$entry"
        src="$RICE_REPO/$src"
        dest="$HOME/$dest"
        case "$type" in
            file)
                if [[ -f "$src" && -f "$dest" ]] && ! same_file "$src" "$dest"; then
                    info "diff $dest"
                    diff -u --label "repo:$src" --label "live:$dest" "$src" "$dest" || true
                fi
                ;;
            dir)
                if [[ -d "$src" && -d "$dest" ]]; then
                    local -a opts=(-ru)
                    info "diff $dest/"
                    diff "${opts[@]}" --exclude=.git --exclude='*.log' "$src" "$dest" || true
                fi
                ;;
            zen)
                local profile rel
                profile="$(resolve_zen_profile)"
                [[ -n "$profile" ]] || continue
                for rel in "${RICE_ZEN_FILES[@]}"; do
                    if [[ -f "$src/$rel" && -f "$profile/$rel" ]] && ! same_file "$src/$rel" "$profile/$rel"; then
                        info "diff $profile/$rel"
                        diff -u --label "repo:$src/$rel" --label "live:$profile/$rel" "$src/$rel" "$profile/$rel" || true
                    fi
                done
                ;;
        esac
    done
}
