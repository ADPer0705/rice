#!/usr/bin/env bash
# shellcheck shell=bash
# backup.sh - build and publish a secret-free OpenCode configuration bundle.
#
# Deliberately small: config, skills, MCP definitions and model preferences.
# Sessions, history, snapshots, provider credentials and runtime secrets
# (service.json) are never included.

OC_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
OC_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
OC_BACKUP_STATE="$RICE_STATE/opencode-backup"
OC_KEEP="${RICE_OPENCODE_KEEP:-10}"
OC_LOCAL_KEEP="${RICE_OPENCODE_LOCAL_KEEP:-5}"
OC_TAG_PREFIX="opencode-config"
# Global so the EXIT trap can still see it after opencode_backup returns.
OC_BACKUP_STAGE=""

_opencode_bin() {
    if have opencode; then
        command -v opencode
    elif [[ -x "$HOME/.opencode/bin/opencode" ]]; then
        printf '%s\n' "$HOME/.opencode/bin/opencode"
    else
        return 1
    fi
}

_opencode_version() {
    local bin
    if bin="$(_opencode_bin)"; then
        "$bin" --version 2>/dev/null | head -1
    else
        printf 'unknown'
    fi
}

_opencode_repo_slug() {
    local url
    url="$(git -C "$RICE_REPO" remote get-url origin 2>/dev/null || true)"
    url="${url#git@github.com:}"
    url="${url#https://github.com/}"
    printf '%s\n' "${url%.git}"
}

# Fail closed: nothing is archived or published while a credentials-shaped
# string is present in the staged tree.
_opencode_secret_scan() {
    local dir="$1" hits
    hits="$(grep -rInE '(sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|Bearer [A-Za-z0-9._~+/-]{20,}|outpost\.[A-Za-z0-9]{8,}|-----BEGIN [A-Z ]*PRIVATE KEY-----)' "$dir" || true)"
    if [[ -n "$hits" ]]; then
        err "refusing to publish: credentials-shaped string in the bundle"
        # Report location only; never echo the matching value.
        printf '%s\n' "$hits" | cut -d: -f1,2 | sed 's/^/  /' >&2
        return 1
    fi
}

_opencode_content_hash() {
    local stage="$1"
    (
        cd "$stage" || exit 1
        find . -type f ! -name MANIFEST -print0 | sort -z | xargs -0 sha256sum
    ) | sha256sum | cut -d' ' -f1
}

_opencode_write_restore() {
    local file="$1"
    cat >"$file" <<'RESTORE'
#!/usr/bin/env bash
# Restore this OpenCode configuration bundle.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/opencode"

mkdir -p "$config_dir" "$state_dir"
cp -a "$here/config/." "$config_dir/"
if [[ -f "$here/state/model.json" ]]; then
    cp -a "$here/state/model.json" "$state_dir/model.json"
fi

printf 'restored config -> %s\n' "$config_dir"
printf 'restored prefs  -> %s/model.json\n' "$state_dir"

if [[ ! -s "$HOME/.secrets/outpost.token" ]]; then
    cat <<'EOF'

ACTION REQUIRED: the outpost MCP reads its bearer token from
  ~/.secrets/outpost.token
That file is intentionally not part of this bundle. Create it (no trailing
newline) with the token, then run: opencode reload
EOF
fi

cat <<'EOF'

Next steps:
  opencode upgrade     # match the version recorded in MANIFEST
  opencode auth login  # DeepSeek / Mistral / OpenCode Console
  opencode mcp list    # expect openwiki, playwright, outpost connected
EOF
RESTORE
    chmod 0755 "$file"
}

_opencode_build() {
    local stage="$1"
    mkdir -p "$stage/opencode-config"

    if [[ ! -d "$OC_CONFIG" ]]; then
        die "no OpenCode config at $OC_CONFIG"
    fi
    rsync -a --exclude=service.json "$OC_CONFIG/" "$stage/opencode-config/config/"
    if [[ -f "$OC_STATE/model.json" ]]; then
        mkdir -p "$stage/opencode-config/state"
        cp -a "$OC_STATE/model.json" "$stage/opencode-config/state/model.json"
    fi
    _opencode_write_restore "$stage/opencode-config/restore.sh"

    (
        cd "$stage/opencode-config" || exit 1
        {
            printf 'rice OpenCode configuration bundle\n'
            printf 'created   %s\n' "$(date -Iseconds)"
            printf 'host      %s\n' "$(hostname)"
            printf 'opencode  %s\n' "$(_opencode_version)"
            printf 'rice      %s\n' "$(git -C "$RICE_REPO" rev-parse --short HEAD 2>/dev/null || echo unknown)"
            printf 'contents  config/ (service.json excluded), state/model.json\n'
            printf '\nfiles\n'
            find . -type f ! -name MANIFEST -print0 | sort -z | xargs -0 sha256sum
        } >MANIFEST
    )
}

_opencode_prune_local() {
    local keep="$1"
    local -a archives=()
    mapfile -t archives < <(find "$OC_BACKUP_STATE" -maxdepth 1 -name "$OC_TAG_PREFIX-*.tar.zst" -printf '%T@ %p\n' 2>/dev/null \
        | sort -nr | cut -d' ' -f2-)
    (( ${#archives[@]} > keep )) || return 0
    local f
    for f in "${archives[@]:keep}"; do
        rm -f "$f" "$f.sha256"
        dim "  pruned $(basename "$f")"
    done
}

_opencode_prune_releases() {
    local keep="$1" slug="$2" tag
    local -a tags=()
    mapfile -t tags < <(
        gh release list -R "$slug" --limit 100 --json tagName,createdAt \
            --jq 'sort_by(.createdAt) | reverse | .[].tagName' 2>/dev/null \
            | grep "^$OC_TAG_PREFIX-" || true
    )
    (( ${#tags[@]} > keep )) || return 0
    for tag in "${tags[@]:keep}"; do
        if gh release delete "$tag" -R "$slug" --yes --cleanup-tag >/dev/null 2>&1; then
            dim "  pruned release $tag"
        fi
    done
}

opencode_backup_verify() {
    local archive="$1"
    [[ -f "$archive" ]] || die "no such bundle: $archive"
    local tmp root
    tmp="$(mktemp -d)"
    tar -xf "$archive" -C "$tmp"
    root="$(find "$tmp" -maxdepth 1 -mindepth 1 -type d | head -1)"
    if [[ ! -f "$root/MANIFEST" ]]; then
        rm -rf "$tmp"
        die "bundle has no MANIFEST"
    fi
    if ( cd "$root" && sed -n '/^files$/,$p' MANIFEST | tail -n +2 | sha256sum -c --quiet - ); then
        ok "bundle contents match MANIFEST"
    else
        rm -rf "$tmp"
        die "bundle checksum mismatch"
    fi
    if [[ -f "$archive.sha256" ]] && ( cd "$(dirname "$archive")" && sha256sum -c --quiet "$(basename "$archive").sha256" ); then
        ok "archive checksum matches"
    fi
    if _opencode_secret_scan "$tmp"; then
        ok "no credentials-shaped strings in bundle"
    else
        rm -rf "$tmp"
        return 1
    fi
    printf '  %s\n' "$(grep -E '^(created|opencode|rice) ' "$root/MANIFEST" | sed 's/^/  /')"
    rm -rf "$tmp"
}

opencode_backup() {
    local publish=1 verify=0 force=0 arg
    for arg in "$@"; do
        case "$arg" in
            --no-release) publish=0 ;;
            --verify) verify=1 ;;
            --force) force=1 ;;
            *) die "unknown backup option: $arg" ;;
        esac
    done

    ensure_state
    mkdir -p "$OC_BACKUP_STATE"

    local stage tag archive content_hash previous_hash=""
    stage="$(mktemp -d)"
    OC_BACKUP_STAGE="$stage"
    trap 'rm -rf "${OC_BACKUP_STAGE:-}"' EXIT

    info "staging OpenCode configuration"
    _opencode_build "$stage"
    _opencode_secret_scan "$stage" || die "bundle rejected by secret scan"

    content_hash="$(_opencode_content_hash "$stage/opencode-config")"
    [[ -f "$OC_BACKUP_STATE/last.hash" ]] && previous_hash="$(cat "$OC_BACKUP_STATE/last.hash")"

    tag="$OC_TAG_PREFIX-$(date +%Y%m%d)"
    archive="$OC_BACKUP_STATE/$tag.tar.zst"

    if [[ "$content_hash" == "$previous_hash" ]] && [[ "$force" == 0 ]] && [[ -f "$archive" ]]; then
        ok "configuration unchanged since last backup ($tag); nothing to do"
        if [[ "$verify" == 1 ]]; then
            opencode_backup_verify "$archive"
        fi
        return 0
    fi

    if [[ -e "$archive" ]]; then
        tag="$OC_TAG_PREFIX-$(date +%Y%m%d-%H%M)"
        archive="$OC_BACKUP_STATE/$tag.tar.zst"
    fi

    tar -C "$stage" -cf - . | zstd -19 -T0 -q -o "$archive"
    ( cd "$OC_BACKUP_STATE" && sha256sum "$(basename "$archive")" > "$(basename "$archive").sha256" )
    printf '%s\n' "$content_hash" >"$OC_BACKUP_STATE/last.hash"
    ok "built $(basename "$archive") ($(du -h "$archive" | cut -f1))"

    if [[ "$publish" == 1 ]]; then
        if have gh && gh auth status >/dev/null 2>&1; then
            local slug
            slug="$(_opencode_repo_slug)"
            if gh release view "$tag" -R "$slug" >/dev/null 2>&1; then
                gh release upload "$tag" "$archive" "$archive.sha256" -R "$slug" --clobber >/dev/null
                ok "updated release $tag (gh/$slug)"
            else
                gh release create "$tag" "$archive" "$archive.sha256" -R "$slug" \
                    --title "OpenCode config $tag" \
                    --notes "Secret-free OpenCode configuration bundle. Restore: tar -xf ${tag}.tar.zst && bash opencode-config/restore.sh" \
                    >/dev/null
                ok "published release $tag (gh/$slug)"
            fi
            _opencode_prune_releases "$OC_KEEP" "$slug"
        else
            warn "gh unavailable or not authenticated; bundle is local only"
        fi
    fi

    _opencode_prune_local "$OC_LOCAL_KEEP"

    if [[ "$verify" == 1 ]]; then
        opencode_backup_verify "$archive"
    fi
}
