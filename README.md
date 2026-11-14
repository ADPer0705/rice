<div align="center">

# ⛩️ rice

**ADPer's Fedora + Hyprland setup, versioned.**

A reproducible slice of my desktop: shell, terminal, editor, window manager,
bar, launcher, fonts, task tracking and the small scripts that keep it all
captured.

[![Fedora](https://img.shields.io/badge/Fedora-45-51a2da?logo=fedora&logoColor=white)](https://fedoraproject.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-0.57-58e1ff)](https://hyprland.org/)
[![Neovim](https://img.shields.io/badge/Neovim-0.12-57a143?logo=neovim&logoColor=white)](https://neovim.io/)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

<img src="assets/wallpapers/wp11450522-cyberpunk-style-wallpapers.jpg" alt="Current wallpaper" width="720">

</div>

## What's inside

| Area | Tool | Config |
| --- | --- | --- |
| Window manager | [Hyprland](https://hyprland.org/) (Lua config) | `home/.config/hypr/` |
| Bar | [Waybar](https://github.com/Alexays/Waybar) | `home/.config/waybar/` |
| Launcher | [Fuzzel](https://codeberg.org/dnkl/fuzzel) | `home/.config/fuzzel/` |
| Terminal | [Ghostty](https://ghostty.org/) | `home/.config/ghostty/` |
| Shell | [Zsh](https://www.zsh.org/) + Oh My Zsh + Starship | `home/.zshrc`, `home/.config/starship.toml` |
| Multiplexer | [tmux](https://github.com/tmux/tmux) + resurrect | `home/.tmux.conf` |
| Editor | [Neovim](https://neovim.io/) (lazy.nvim) | `home/.config/nvim/` |
| Tasks | [Taskwarrior](https://taskwarrior.org/) | `home/.taskrc` |
| Browser | [Zen](https://zen-browser.app/) | `home/.zen/profile/` |
| Documents | [MinerU](https://github.com/opendatalab/MinerU) | `home/mineru.json` |
| Fonts / cursors | JetBrainsMono NF, Catppuccin Mocha | `assets/` |
| CPU tuning | [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq) | `system/` |
| Boot | Fedora grub defaults | `system/etc/default/grub` |

Detailed notes live in [`docs/`](docs/): [install](docs/install.md),
[keybindings](docs/keybinds.md), [theming](docs/theming.md),
[Zen](docs/zen.md), [MinerU](docs/mineru.md),
[troubleshooting](docs/troubleshooting.md).

## Quick start

On a fresh Fedora install:

```bash
git clone git@github.com:ADPer0705/rice.git
cd rice

bash bootstrap.sh          # packages + tools + deploy configs
bash bin/rice system       # preview root-owned files (grub, auto-cpufreq)
bash bin/rice timer install
```

Useful commands:

```bash
bash bin/rice status       # repo <-> $HOME drift
bash bin/rice diff         # unified diff for drifted paths
bash bin/rice deploy       # repo -> $HOME (backs up what it replaces)
bash bin/rice sync         # $HOME -> repo, commit, push
bash bin/rice doctor       # deps, mount, remote, timer
```

> The repo can live on an NTFS drive, but the working tree loses exec bits
> there. Always run scripts as `bash bin/rice …`. On ext4 the exec bits from
> git work normally.

## How it works

This is **copy-based**, not symlink-based:

```
$HOME  ──sync──▶  repo  ──commit/push──▶  GitHub
  ▲                                          │
  └──────────── deploy ◀──── pull ◀──────────┘
```

- `deploy` copies `home/` into `$HOME`, backing up every replaced file to
  `~/.local/state/rice/backups/<timestamp>/`
- `sync` captures the live config back into the repo, refreshes
  `packages/versions.txt` and `packages/dnf-snapshot.txt`, scans for secrets,
  commits, and pushes
- a daily `systemd --user` timer runs `sync` at 18:00 (±10 min), guarded by
  `flock` and `RequiresMountsFor=/mnt/s`
- `status` / `diff` show what changed before you overwrite either side

Nothing machine-specific is tracked: `~/.zshrc.local` is sourced if present and
is ignored by git.

## Repository layout

```
rice/
├── bin/rice                 # install | deploy | sync | status | diff | system | timer
├── bootstrap.sh             # fresh-machine entry point
├── Makefile                 # short wrappers around bin/rice
├── home/                    # mirrors $HOME; deployed with rsync
│   ├── .zshrc .tmux.conf .taskrc
│   ├── .config/{nvim,hypr,waybar,fuzzel,ghostty,fontconfig,starship.toml}
│   └── .zen/profile/        # curated Zen files only
├── system/                  # root-owned files (applied opt-in with sudo)
├── packages/                # curated dnf/copr/flatpak lists + versions
├── assets/                  # fonts, cursors, wallpapers, excalidraw libs
├── docs/                    # install, keybinds, theming, zen, mineru, notes
└── archive/                 # old configs kept for reference
```

## Machine notes

- **Fedora 45 KDE**, Hyprland 0.57.2. KDE is still the fallback session; the
  Hyprland look is separate and not yet unified with the KDE theme.
- **Monitor** `eDP-1`, 2560x1600 @ 165 Hz, scale 1.25. Change it in
  `home/.config/hypr/hyprland.lua` if your panel differs.
- **Grub** is templated: the actual LUKS UUID is filled in from the running
  machine by `rice system`. Regenerating grub is opt-in.
- **auto-cpufreq** is installed from upstream into `/opt`, not from dnf.
  A Python minor upgrade breaks its venv; re-run the installer.

## Credits

- [Catppuccin](https://github.com/catppuccin) for the cursor themes
- [Nerd Fonts](https://www.nerdfonts.com/) for JetBrainsMono NF
- The Hyprland, Waybar, Fuzzel, Ghostty and Neovim communities
- Wallpapers are collected from the web; rights belong to their authors

## License

[MIT](LICENSE) for the configs and scripts in this repo. Third-party assets
keep their own licenses.
