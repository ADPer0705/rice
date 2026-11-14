#!/usr/bin/env bash
# shellcheck shell=bash
# packages.sh - reproducible installation of the non-config half of the setup.

_run() {
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would run: $*"
    else
        "$@"
    fi
}

_sudo() {
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would run: sudo $*"
    else
        sudo "$@"
    fi
}

enable_copr() {
    have dnf || return 0
    local repo
    while IFS= read -r repo; do
        [[ "$repo" =~ ^[[:space:]]*# || -z "${repo// }" ]] && continue
        info "COPR: $repo"
        _sudo dnf copr enable -y "$repo"
    done < "$RICE_REPO/packages/copr.txt"
}

install_dnf() {
    have dnf || { warn "dnf not found; skipping Fedora packages"; return 0; }
    local -a pkgs=()
    mapfile -t pkgs < <(grep -vE '^[[:space:]]*(#|$)' "$RICE_REPO/packages/dnf.txt")
    [[ ${#pkgs[@]} -gt 0 ]] || return 0
    info "dnf: ${#pkgs[@]} packages"
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would install: ${pkgs[*]}"
        return 0
    fi
    sudo -v
    sudo dnf install -y --skip-unavailable "${pkgs[@]}"
}

install_flatpaks() {
    have flatpak || { warn "flatpak not found; skipping"; return 0; }
    local -a apps=()
    mapfile -t apps < <(grep -vE '^[[:space:]]*(#|$)' "$RICE_REPO/packages/flatpak.txt")
    [[ ${#apps[@]} -gt 0 ]] || return 0
    info "flatpak: ${#apps[@]} apps"
    if ! flatpak remotes --columns=name 2>/dev/null | grep -qx flathub; then
        _sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    local app
    for app in "${apps[@]}"; do
        if flatpak list --app --columns=application 2>/dev/null | grep -qx "$app"; then
            continue
        fi
        _run flatpak install -y flathub "$app"
    done
}

_ensure_clone() {
    local dest="$1" url="$2" commit="${3:-}"
    if [[ -d "$dest/.git" ]]; then
        dim "  exists: $dest"
        return 0
    fi
    [[ "$DRY_RUN" == 1 ]] && { dim "  would clone $url -> $dest"; return 0; }
    mkdir -p "$(dirname "$dest")"
    git clone --quiet "$url" "$dest"
    if [[ -n "$commit" ]]; then
        if ! git -C "$dest" checkout --quiet "$commit" 2>/dev/null; then
            git -C "$dest" fetch --quiet origin "$commit" 2>/dev/null || true
            git -C "$dest" checkout --quiet "$commit" 2>/dev/null \
                || warn "could not check out $commit in $dest (left on default branch)"
        fi
    fi
    ok "cloned $dest"
}

install_shell() {
    info "zsh: oh-my-zsh + plugins"
    _ensure_clone "$HOME/.oh-my-zsh" "https://github.com/ohmyzsh/ohmyzsh.git" "b509b1c6ed0c1ba37de12cbd37f30b2b2f61193a"
    local line name url commit dest
    while IFS='|' read -r name url commit; do
        [[ "$name" =~ ^# || -z "$name" ]] && continue
        dest="$HOME/.oh-my-zsh/custom/plugins/$name"
        _ensure_clone "$dest" "$url" "$commit"
    done < "$RICE_REPO/packages/zsh-plugins.txt"
}

install_tmux_plugins() {
    info "tmux: tpm + resurrect"
    _ensure_clone "$HOME/.tmux/plugins/tpm" "https://github.com/tmux-plugins/tpm" "e261deb1b476"
    _ensure_clone "$HOME/.tmux/plugins/tmux-resurrect" "https://github.com/tmux-plugins/tmux-resurrect" "cff343cf9e81"
}

install_starship() {
    if have starship; then
        dim "  starship already installed: $(starship --version | head -1)"
        return 0
    fi
    info "starship 1.25.1"
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would run the starship installer"
        return 0
    fi
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y --version 1.25.1
}

install_uv() {
    if have uv; then
        dim "  uv already installed: $(uv --version)"
        return 0
    fi
    info "uv 0.11.29"
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would run the uv installer"
        return 0
    fi
    curl -LsSf https://astral.sh/uv/install.sh | env UV_VERSION=0.11.29 sh
    export PATH="$HOME/.local/bin:$PATH"
}

install_uv_tools() {
    have uv || { warn "uv not available; skipping uv tools"; return 0; }
    info "uv tools"
    local line
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# || -z "${line// }" ]] && continue
        _run uv tool install "$line"
    done < "$RICE_REPO/packages/uv-tools.txt"
}

install_go_tools() {
    have go || { warn "go not found; skipping Go tools"; return 0; }
    info "Go tools"
    local line
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# || -z "${line// }" ]] && continue
        _run go install "$line"
    done < "$RICE_REPO/packages/go-tools.txt"
}

install_rust() {
    if have rust-analyzer && have rustfmt && have cargo; then
        dim "  rust toolchain already present"
        return 0
    fi
    info "rustup (rust-analyzer, rustfmt, clippy)"
    if [[ "$DRY_RUN" == 1 ]]; then
        dim "  would run rustup-init"
        return 0
    fi
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path --profile minimal \
            --default-toolchain stable -c rust-analyzer -c rustfmt -c clippy
    export PATH="$HOME/.cargo/bin:$PATH"
}

install_all() {
    local arg
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=1 ;;
            --no-rust) RICE_NO_RUST=1 ;;
            *) die "unknown install option: $arg" ;;
        esac
    done
    enable_copr
    install_dnf
    install_flatpaks
    install_shell
    install_tmux_plugins
    install_starship
    install_uv
    install_uv_tools
    install_go_tools
    [[ "${RICE_NO_RUST:-0}" == 1 ]] || install_rust
    info "package installation complete"
    dim "next: bash bin/rice deploy"
}
