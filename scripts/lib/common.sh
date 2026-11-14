#!/usr/bin/env bash
# shellcheck shell=bash
# Shared helpers for bin/rice. Sourced, never executed directly.

set -euo pipefail

RICE_REPO="${RICE_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
RICE_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
RICE_BACKUP_ROOT="$RICE_STATE/backups"
RICE_BACKUP_DIR="$RICE_BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
RICE_LOG="$RICE_STATE/sync.log"

if [[ -t 1 ]]; then
    C_RESET=$'\033[0m'
    C_BLUE=$'\033[34m'
    C_GREEN=$'\033[32m'
    C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'
    C_DIM=$'\033[2m'
else
    C_RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""; C_DIM=""
fi

info() { printf '%s==>%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
ok()   { printf '%s ok %s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '%s  ! %s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; }
err()  { printf '%s xx %s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
die()  { err "$*"; exit 1; }
dim()  { printf '%s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }

have() { command -v "$1" >/dev/null 2>&1; }

ensure_state() {
    mkdir -p "$RICE_STATE"
}

need_cmd() {
    have "$1" || die "missing dependency: $1"
}

# Backup a file or directory before overwriting it. Keeps the path relative
# to $HOME so the backup layout mirrors the live layout.
backup_target() {
    local target="$1"
    local rel="${target#"$HOME"/}"
    [[ "$rel" == "$target" ]] && rel="absolute/${target#/}"
    [[ -e "$target" || -L "$target" ]] || return 0
    local dest="$RICE_BACKUP_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    cp -a "$target" "$dest"
    dim "  backup: $target -> $dest"
}

# Compare a repo source with a live target.
same_file() {
    cmp -s "$1" "$2" 2>/dev/null
}

# Return 0 when an rsync copy would change nothing. $@ is passed to rsync.
rsync_is_clean() {
    local out
    out="$(rsync -ani "$@" 2>/dev/null || true)"
    [[ -z "$out" ]]
}

require_repo() {
    [[ -d "$RICE_REPO/.git" ]] || die "not a git repo: $RICE_REPO"
}
