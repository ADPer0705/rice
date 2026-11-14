# Theming

The desktop is mid-migration: KDE Plasma is still the fallback session, and
Hyprland has its own hand-written look. This page records both so the eventual
port has a source of truth.

## Current KDE look (snapshot)

Captured under `docs/theming/kde/`:

| Setting | Value |
| --- | --- |
| Global theme / Look-and-Feel | `Catppuccin-Mocha-Blue` |
| Plasma style | `org.kde.breezedark.desktop` |
| UI font | Noto Sans 10 |
| GTK theme | Breeze (dark) |
| GTK icon theme | Breeze |
| GTK cursor | `breeze_cursors`, size 24 |
| Window decoration | Breeze |

The full files are `kdeglobals`, `kcminputrc` and `gtk-3.0/settings.ini`.
KDE theme assets themselves (`aurorae`, `plasma`, color schemes) are **not**
committed yet.

## Current Hyprland look

A dark "HUD" palette, independent of the KDE theme:

| Element | Value |
| --- | --- |
| Terminal | Ghostty, `#060d18` background, `#00f0ff` accent |
| Launcher | Fuzzel, same palette, JetBrainsMono Nerd Font 12 |
| Bar | Waybar, transparent, `#e0f7fa` text, JetBrainsMono Nerd Font 12 |
| Wallpaper | `assets/wallpapers/` |
| Notifications | mako |
| Cursors | Catppuccin Mocha (Blue/Dark/Sky installed) |

Ghostty's config keeps a Catppuccin Mocha block first and the Stark HUD block
after it; the later assignments win.

## Fonts and icons

| Asset | Location in repo | Installed to |
| --- | --- | --- |
| JetBrainsMono Nerd Font (Regular) | `assets/fonts/` | `~/.local/share/fonts/` |
| Catppuccin Mocha cursors (3 variants) | `assets/icons/` | `~/.local/share/icons/` |

`bin/rice deploy` copies both and runs `fc-cache -f`.

## Porting checklist (later)

- [ ] Pick one palette for Hyprland + GTK + Qt (Catppuccin Mocha vs Stark HUD)
- [ ] Set `XCURSOR_THEME` in Hyprland and GTK `gtk-cursor-theme-name`
- [ ] Add a `fontconfig` rule mapping `sans-serif` to Noto Sans and monospace
      to JetBrainsMono NF
- [ ] Decide whether to keep Breeze icons or move to Papirus/Catppuccin
- [ ] Style Qt apps (`qt5ct`/`qt6ct` or Kvantum) so they match
- [ ] Theme `mako`, `hyprlock`, `hyprpaper` consistently
- [ ] Snapshot the chosen KDE theme assets into the repo once final
