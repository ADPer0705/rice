#!/usr/bin/env bash
# shellcheck shell=bash
# system.sh - root-owned files (/etc). Always dry-run unless --write is given.

SYS_BACKUP_ROOT="/var/lib/rice/backups"

_grub_luks_uuid() {
    local uuid=""
    if [[ -f /etc/default/grub ]]; then
        uuid="$(grep -oE 'rd\.luks\.uuid=luks-[0-9a-fA-F-]{36}' /etc/default/grub \
            | head -1 | sed 's/.*luks-//' || true)"
    fi
    if [[ -z "$uuid" ]] && have blkid; then
        uuid="$(blkid -t TYPE=crypto_LUKS -o value -s UUID 2>/dev/null | head -1 || true)"
    fi
    printf '%s\n' "$uuid"
}

_grub_render() {
    local src="$1" uuid
    uuid="$(_grub_luks_uuid)"
    [[ -n "$uuid" ]] || die "cannot determine the LUKS UUID; refusing to render grub config"
    sed "s/luks-__LUKS_UUID__/luks-$uuid/g" "$src"
}

system_sync() {
    info "capturing root-owned files"
    if [[ -f /etc/default/grub ]]; then
        if [[ "$DRY_RUN" == 1 ]]; then
            dim "  would capture /etc/default/grub"
        else
            sed 's/luks-[0-9a-fA-F-]\{36\}/luks-__LUKS_UUID__/' /etc/default/grub \
                > "$RICE_REPO/system/etc/default/grub"
            ok "captured /etc/default/grub"
        fi
    fi
    if [[ -f /etc/systemd/system/auto-cpufreq.service ]]; then
        if [[ "$DRY_RUN" == 1 ]]; then
            dim "  would capture auto-cpufreq.service"
        else
            cp -a /etc/systemd/system/auto-cpufreq.service \
                "$RICE_REPO/system/systemd/auto-cpufreq.service"
            ok "captured auto-cpufreq.service"
        fi
    fi
}

system_apply() {
    local write=0 regenerate=0
    local arg
    for arg in "$@"; do
        case "$arg" in
            --write) write=1 ;;
            --regenerate) regenerate=1 ;;
            --dry-run) DRY_RUN=1 ;;
            *) die "unknown system option: $arg" ;;
        esac
    done
    need_cmd sudo

    info "system files (dry-run unless --write)"
    local rendered
    rendered="$(_grub_render "$RICE_REPO/system/etc/default/grub")"
    if [[ -f /etc/default/grub ]] && diff -q <(printf '%s\n' "$rendered") /etc/default/grub >/dev/null 2>&1; then
        ok "/etc/default/grub already matches"
    else
        info "diff for /etc/default/grub"
        diff -u /etc/default/grub <(printf '%s\n' "$rendered") || true
        if [[ "$write" == 1 && "$DRY_RUN" != 1 ]]; then
            local stamp
            stamp="$(date +%Y%m%d-%H%M%S)"
            sudo mkdir -p "$SYS_BACKUP_ROOT/$stamp/etc/default"
            sudo cp -a /etc/default/grub "$SYS_BACKUP_ROOT/$stamp/etc/default/grub"
            printf '%s\n' "$rendered" | sudo tee /etc/default/grub >/dev/null
            ok "wrote /etc/default/grub (backup: $SYS_BACKUP_ROOT/$stamp)"
        fi
    fi

    if [[ "$regenerate" == 1 ]]; then
        if [[ "$DRY_RUN" == 1 || "$write" != 1 ]]; then
            dim "  would run: sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
        else
            info "regenerating grub"
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            ok "grub regenerated"
        fi
    fi

    local unit_src="$RICE_REPO/system/systemd/auto-cpufreq.service"
    local unit_dst="/etc/systemd/system/auto-cpufreq.service"
    if [[ -f "$unit_src" ]]; then
        if [[ -f "$unit_dst" ]] && cmp -s "$unit_src" "$unit_dst"; then
            ok "$unit_dst already matches"
        elif [[ "$write" == 1 && "$DRY_RUN" != 1 ]]; then
            sudo install -D -m 0644 "$unit_src" "$unit_dst"
            sudo systemctl daemon-reload
            ok "installed $unit_dst"
        else
            dim "  would install $unit_dst"
        fi
    fi

    local conf="/etc/auto-cpufreq.conf"
    if [[ -f "$conf" ]]; then
        ok "$conf exists (left untouched)"
    else
        dim "  $conf is absent; auto-cpufreq uses defaults (see system/etc/auto-cpufreq.conf.example)"
    fi

    if [[ "$write" == 1 ]]; then
        info "enabling auto-cpufreq"
        sudo systemctl enable --now auto-cpufreq.service 2>/dev/null || warn "could not enable auto-cpufreq"
    fi
}
