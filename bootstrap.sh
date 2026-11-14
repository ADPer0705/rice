#!/usr/bin/env bash
# bootstrap.sh - install the stack, then copy the configs into $HOME.
# Run as: bash bootstrap.sh [--dry-run] [--no-rust]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
    esac
done

echo
echo "  ⛩  ADPer's rice - bootstrap"
echo "  repo: $REPO_DIR"
echo

bash "$REPO_DIR/bin/rice" install "$@"

if [[ "$DRY_RUN" == 1 ]]; then
    bash "$REPO_DIR/bin/rice" deploy --dry-run
else
    bash "$REPO_DIR/bin/rice" deploy
fi

cat <<'EOF'

Next steps
  1. Log out and back in (or start Hyprland) so the new shell/desktop loads.
  2. Optional, root-owned files:   bash bin/rice system --write
  3. Optional, grub regeneration:  bash bin/rice system --write --regenerate
  4. Daily capture timer:          bash bin/rice timer install
  5. Launch Zen once, then:        bash bin/rice deploy

Machine-local secrets go in ~/.zshrc.local (never tracked).
EOF
