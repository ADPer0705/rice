# Install

Target: Fedora 45 KDE (the reference machine), with Hyprland as the Wayland
session. Most of the repo is distro-agnostic, but the package script is dnf
specific.

## 1. Clone

```bash
git clone git@github.com:ADPer0705/rice.git
cd rice
```

The repo can live on any filesystem. On NTFS/FUSE the working tree loses exec
bits, so always run scripts with `bash` (`bash bin/rice …`).

## 2. Install packages and tooling

```bash
bash bootstrap.sh
```

This enables the required COPR repositories, installs the curated dnf list,
Flatpaks, Oh My Zsh + plugins, TPM + resurrect, Starship, uv, the pinned uv
tools, Go tools and (unless `--no-rust`) rustup. It then copies the configs
into `$HOME`.

Useful variants:

```bash
bash bin/rice install --dry-run    # show what would happen
bash bin/rice install --no-rust    # skip the Rust toolchain
bash bin/rice deploy --dry-run     # only preview the config copy
```

## 3. Root-owned files (optional)

```bash
bash bin/rice system                 # preview; never writes
bash bin/rice system --write         # install /etc/default/grub + auto-cpufreq unit
bash bin/rice system --write --regenerate   # also run grub2-mkconfig
```

The grub template contains `__LUKS_UUID__`; `rice system` substitutes the UUID
found on the current machine and refuses to render if it cannot find one.
Regenerating grub is opt-in because it is easy to make the boot menu worse.

## 4. Post-install

```bash
# Zen: launch it once so it creates a profile, then:
bash bin/rice deploy

# zsh is not set as the login shell automatically:
chsh -s "$(command -v zsh)"

# daily capture timer (18:00 local, ±10 min)
bash bin/rice timer install
```

Log out and back in, then start the Hyprland session.

## 5. Verify

```bash
bash bin/rice status     # repo <-> $HOME
bash bin/rice doctor     # deps, mount, remote, timer
bash bin/rice diff       # unified diff for drifted paths
```

## Package sources

| Stack | Source |
| --- | --- |
| Hyprland, hyprpaper, hypridle, hyprlock, hyprshutdown | COPR `lionheartp/Hyprland` |
| Ghostty | COPR `scottames/ghostty` |
| Zen Browser | COPR `sneexy/zen-browser` |
| Everything else in `packages/dnf.txt` | Fedora |
| Obsidian, Telegram | Flathub |

The full installed-package snapshot is `packages/dnf-snapshot.txt` for
reference only; do not try to install all 8,800 packages on a fresh machine.
