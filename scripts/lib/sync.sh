#!/usr/bin/env bash
# shellcheck shell=bash
# sync.sh - capture live config, refresh snapshots, commit and optionally push.

RICE_PUSH="${RICE_PUSH:-1}"
RICE_QUIET="${RICE_QUIET:-0}"

_versions_file() {
    local os_name kernel
    os_name="$(. /etc/os-release 2>/dev/null && printf '%s %s' "$NAME" "$VERSION")"
    kernel="$(uname -r)"
    {
        printf '# Captured from the reference machine (%s)\n' "$os_name"
        printf '# Regenerate with: bash bin/rice sync\n\n'
        printf '%-16s %s\n' "os" "$os_name"
        printf '%-16s %s\n' "kernel" "$kernel"
        printf '\n'
        printf '%-16s %s\n' "hyprland" "$(hyprctl version 2>/dev/null | head -1 | awk '{print $2}')"
        printf '%-16s %s\n' "waybar" "$(waybar --version 2>/dev/null)"
        printf '%-16s %s\n' "fuzzel" "$(fuzzel --version 2>/dev/null | sed 's/.*version: //')"
        printf '%-16s %s\n' "ghostty" "$(ghostty --version 2>/dev/null | head -1)"
        printf '%-16s %s\n' "zen-browser" "$(zen-browser --version 2>/dev/null)"
        printf '%-16s %s\n' "neovim" "$(nvim --version 2>/dev/null | head -1)"
        printf '%-16s %s\n' "zsh" "$(zsh --version 2>/dev/null | cut -d' ' -f1-2)"
        printf '%-16s %s\n' "tmux" "$(tmux -V 2>/dev/null)"
        printf '%-16s %s\n' "taskwarrior" "$(task --version 2>/dev/null)"
        printf '%-16s %s\n' "starship" "$(starship --version 2>/dev/null | head -1)"
        printf '%-16s %s\n' "uv" "$(uv --version 2>/dev/null)"
        printf '%-16s %s\n' "mineru" "$(mineru --version 2>/dev/null | head -1 | sed 's/MinerU version: //')"
        printf '%-16s %s\n' "git" "$(git --version 2>/dev/null | awk '{print $3}')"
    } > "$RICE_REPO/packages/versions.txt"
}

_snapshot_file() {
    local out="$1"; shift
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would refresh ${out#"$RICE_REPO"/}"
        return 0
    fi
    "$@" > "$out"
}

refresh_snapshots() {
    info "refreshing package and version snapshots"
    _snapshot_file "$RICE_REPO/packages/versions.txt" _versions_file
    if have dnf; then
        _snapshot_file "$RICE_REPO/packages/dnf-snapshot.txt" \
            bash -c "dnf repoquery --installed --qf '%{name}\n' 2>/dev/null | sort -u"
    fi
    if have flatpak; then
        _snapshot_file "$RICE_REPO/packages/flatpak-snapshot.txt" \
            bash -c "flatpak list --app --columns=application,origin 2>/dev/null | sort"
    fi
    if have uv; then
        # `uv tool list` warns about malformed tools on stderr; keep the
        # snapshot deterministic by capturing stdout only.
        _snapshot_file "$RICE_REPO/packages/uv-tools-snapshot.txt" \
            bash -c "uv tool list 2>/dev/null"
    fi
}

sync_extras() {
    info "capturing reference snapshots"
    local -a kde=(
        ".config/kdeglobals:docs/theming/kde/kdeglobals"
        ".config/kcminputrc:docs/theming/kde/kcminputrc"
        ".config/gtk-3.0/settings.ini:docs/theming/kde/gtk-3.0-settings.ini"
    )
    local pair from to
    for pair in "${kde[@]}"; do
        from="$HOME/${pair%%:*}"
        to="$RICE_REPO/${pair#*:}"
        [[ -f "$from" ]] || continue
        if [[ "$DRY_RUN" == 1 ]]; then
            dim "  would capture $from"
        else
            cp -a "$from" "$to"
        fi
    done
    system_sync
}

_secret_scan() {
    local diff
    diff="$(git -C "$RICE_REPO" diff --cached -U0 -- . ':(exclude)packages/dnf-snapshot.txt' || true)"
    [[ -z "$diff" ]] && return 0
    local hits
    hits="$(printf '%s\n' "$diff" | grep -nE '^\+[^+].*(sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)' || true)"
    if [[ -n "$hits" ]]; then
        err "possible secret in staged changes:"
        printf '%s\n' "$hits" >&2
        return 1
    fi
    return 0
}

git_capture() {
    require_repo
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would commit and push"
        return 0
    fi
    if ! git -C "$RICE_REPO" remote get-url origin >/dev/null 2>&1; then
        warn "no git remote 'origin'; commit will stay local"
        RICE_PUSH=0
    fi
    if git -C "$RICE_REPO" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        git -C "$RICE_REPO" pull --rebase --autostash --quiet || {
            err "pull --rebase failed; resolve conflicts then re-run"
            return 1
        }
    fi
    git -C "$RICE_REPO" add -A
    if git -C "$RICE_REPO" diff --cached --quiet; then
        ok "no config changes to commit"
        return 0
    fi
    _secret_scan || {
        err "refusing to commit until the secret is removed or ignored"
        return 1
    }
    git -C "$RICE_REPO" commit --quiet -m "chore(sync): capture $(date '+%Y-%m-%d %H:%M')"
    ok "committed $(git -C "$RICE_REPO" rev-parse --short HEAD)"
    if [[ "$RICE_PUSH" == 1 ]]; then
        if git -C "$RICE_REPO" push --quiet origin main 2>/dev/null; then
            ok "pushed to origin/main"
        else
            warn "push failed; commit is safe locally (run git push manually)"
        fi
    fi
}

sync_all() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=1 ;;
            --no-push) RICE_PUSH=0 ;;
            --quiet) RICE_QUIET=1 ;;
            *) die "unknown sync option: $arg" ;;
        esac
    done
    ensure_state
    if have flock; then
        exec 9>"$RICE_STATE/sync.lock"
        flock -n 9 || die "another sync is already running"
    fi
    sync_home
    sync_extras
    refresh_snapshots
    git_capture
}
