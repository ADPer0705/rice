#!/usr/bin/env bash
# shellcheck shell=bash
# timer.sh - install the daily capture timer as a systemd user unit.

RICE_UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

_timer_service() {
    cat <<EOF
[Unit]
Description=Capture rice dotfiles into git
ConditionPathIsMountPoint=/mnt/s
RequiresMountsFor=/mnt/s
After=network-online.target

[Service]
Type=oneshot
WorkingDirectory=$RICE_REPO
Environment=PATH=%h/.local/bin:%h/go/bin:%h/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ExecStart=/usr/bin/bash $RICE_REPO/bin/rice sync --quiet
Nice=10
EOF
}

_timer_timer() {
    cat <<EOF
[Unit]
Description=Daily rice dotfiles capture

[Timer]
OnCalendar=*-*-* 18:00:00
Persistent=true
RandomizedDelaySec=10m
Unit=rice-sync.service

[Install]
WantedBy=timers.target
EOF
}

timer_cmd() {
    local action="${1:-status}"
    case "$action" in
        install)
            need_cmd systemctl
            mkdir -p "$RICE_UNIT_DIR"
            if [[ "$DRY_RUN" == 1 ]]; then
                dim "  would write $RICE_UNIT_DIR/rice-sync.{service,timer}"
                return 0
            fi
            _timer_service > "$RICE_UNIT_DIR/rice-sync.service"
            _timer_timer > "$RICE_UNIT_DIR/rice-sync.timer"
            systemctl --user daemon-reload
            systemctl --user enable --now rice-sync.timer
            ok "installed rice-sync.timer (daily, 18:00 ±10m)"
            systemctl --user list-timers rice-sync.timer --no-pager
            ;;
        uninstall)
            systemctl --user disable --now rice-sync.timer 2>/dev/null || true
            rm -f "$RICE_UNIT_DIR/rice-sync.service" "$RICE_UNIT_DIR/rice-sync.timer"
            systemctl --user daemon-reload
            ok "removed rice-sync.timer"
            ;;
        status)
            systemctl --user status rice-sync.timer --no-pager 2>/dev/null || warn "rice-sync.timer is not installed"
            ;;
        *) die "usage: rice timer {install|uninstall|status}" ;;
    esac
}
