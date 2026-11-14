# Keybindings

## Hyprland

`Super` is the main modifier. Defined in `home/.config/hypr/hyprland.lua`.

| Keys | Action |
| --- | --- |
| `Super + T` | Ghostty |
| `Super + D` | Fuzzel launcher |
| `Super + Q` | Close window |
| `Super + Escape` | Power menu (`~/.local/bin/power-menu`) |
| `Super + V` | Toggle floating |
| `Super + F` | Maximize (keeps gaps/bar) |
| `Super + Shift + F` | True fullscreen |
| `Super + S` | Toggle split |
| `Super + Alt + L` | Lock (`hyprlock`) |
| `Print` / `Super + Shift + S` | Region screenshot to file + clipboard |
| `Ctrl + Print` | Full screenshot to file + clipboard |
| `Super + H/J/K/L` | Focus left/down/up/right |
| `Super + Ctrl + H/J/K/L` | Move window left/down/up/right |
| `Super + 1…9` | Focus workspace |
| `Super + Shift + 1…9` | Move window to workspace |
| `Super + mouse wheel` | Cycle workspaces |
| `Super + Alt + N` | New empty workspace |
| `Super + Alt + Shift + N` | Move window to new empty workspace |
| `Super + grave` | Toggle scratchpad |
| `Super + Shift + grave` | Send window to scratchpad |
| `Super + Ctrl + grave` | Pull window out of scratchpad |
| `Super + drag` | Move window |
| `Super + right-drag` | Resize window |
| Volume / brightness keys | `wpctl` / `brightnessctl` |

## tmux

Prefix is `Ctrl + Space` (not `Ctrl + b`).

| Keys | Action |
| --- | --- |
| `Ctrl + Space`, `:` | Split horizontally |
| `Ctrl + Space`, `"` | Split vertically |
| `Ctrl + Space`, `r` | Reload config |
| `Ctrl + h/j/k/l` | Select pane (no prefix) |
| `Ctrl + Alt + h/j/k/l` | Resize pane (no prefix) |
| `Ctrl + Space`, `y` (copy mode) | Copy to Wayland clipboard via `wl-copy` |

`tmux-resurrect` is installed by bootstrap; save/restore with the standard
`prefix + Ctrl-s` / `prefix + Ctrl-r` bindings.

## Neovim

Leader is `Space`. The full reference lives in
`home/.config/nvim/README.md`; the most-used custom maps are in
`home/.config/nvim/lua/adper/remap.lua`.

| Keys | Action |
| --- | --- |
| `<leader>pv` | Netrw at the current file's directory |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |
| `<leader>d` | Delete without yanking |
| `<leader>s` | Search-and-replace word under cursor |
| `<leader>x` | `chmod +x` current file |
| `<C-d>` / `<C-u>` | Half-page scroll, centered |
| `n` / `N` | Next/prev search result, centered |
| `J` / `K` (visual) | Move selection down/up |
