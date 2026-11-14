-- Monitor: Predator 2560x1600 @ 165Hz at 1.25 scale
hl.monitor({
    output   = "eDP-1",
    mode     = "2560x1600@165",
    position = "0x0",
    scale    = 1.25,
})

local terminal = "ghostty"
local menu     = "fuzzel"

-- Environment variables
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- Autostart services (runs once when Hyprland starts)
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/libexec/lxqt-policykit-agent")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("pidof hypridle >/dev/null || hypridle")
end)

-- Top bar (waybar) is only shown while the current desktop has windows.
-- On an empty desktop nothing but the wallpaper stays on screen.
local function bar_wanted()
    local mon = hl.get_active_monitor()
    if not mon then
        return false
    end

    local special = mon.active_special_workspace
    if special and not special.is_empty then
        return true
    end

    local ws = mon.active_workspace
    return ws ~= nil and not ws.is_empty
end

-- While visible, waybar reserves a top exclusive zone, so the real bar state
-- can be read back from the monitor instead of being tracked manually.
local function bar_visible()
    for _, mon in ipairs(hl.get_monitors()) do
        local reserved = mon.reserved
        if type(reserved) == "table" and (reserved.top or 0) > 0 then
            return true
        end
    end
    return false
end

local bar_syncing = false

local function sync_bar(retry)
    if bar_syncing or (retry or 0) > 3 then
        return
    end

    if bar_wanted() == bar_visible() then
        return
    end

    -- waybar has no explicit show/hide IPC, SIGUSR1 toggles visibility
    bar_syncing = true
    hl.exec_cmd("pkill -USR1 -x waybar")

    hl.timer(function()
        bar_syncing = false
        sync_bar((retry or 0) + 1)
    end, { timeout = 350, type = "oneshot" })
end

for _, event in ipairs({
    "window.open", "window.close", "window.destroy", "window.kill",
    "window.move_to_workspace", "window.fullscreen",
    "workspace.active", "workspace.created", "workspace.removed",
    "workspace.special_active",
}) do
    hl.on(event, function() sync_bar() end)
end

-- Waybar maps its layer after (re)starting: re-check once it is up
hl.on("layer.opened", function(layer)
    if layer and layer.namespace == "waybar" then
        for _, delay in ipairs({ 150, 600 }) do
            hl.timer(function() sync_bar() end, { timeout = delay, type = "oneshot" })
        end
    end
end)

-- Look, feel, layout & touchpad
hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 12,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(00f0ffee)", "rgba(0066ffee)", "rgba(00f0ffee)" }, angle = 45 },
            inactive_border = "rgba(0d2538aa)",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 6,
        -- Window opacity is per-app: Ghostty sets its own background-opacity
        blur = {
            enabled  = true,
            size     = 6,
            passes   = 3,
            vibrancy = 0.2,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    misc = {
        force_default_wallpaper  = 0,
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
    },
    input = {
        kb_layout    = "us",
        follow_mouse = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- All desktops are dynamic: workspaces are created on demand and removed when empty

local mainMod = "SUPER"

-- Apps & window controls
hl.bind(mainMod .. " + T",         hl.dsp.exec_cmd(terminal),               { description = "Open Ghostty" })
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd(menu),                   { description = "Open Fuzzel launcher" })
hl.bind(mainMod .. " + Q",         hl.dsp.window.close(),                   { description = "Close active window" })
hl.bind(mainMod .. " + Escape",    hl.dsp.exec_cmd("$HOME/.local/bin/power-menu"), { description = "Power menu" })
hl.bind(mainMod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",         hl.dsp.window.fullscreen({ mode = "maximized" }))  -- Maximize with bar/gaps
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))  -- True fullscreen
hl.bind(mainMod .. " + S",         hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd("pidof hyprlock >/dev/null || hyprlock"))

-- Screenshots (region -> clipboard + ~/Pictures/Screenshots)
hl.bind("Print",               hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy'))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy'))
hl.bind("CTRL + Print",        hl.dsp.exec_cmd('grim - | tee ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png | wl-copy'))

-- Vim-style focus & window movement
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

-- Switch desktops (1-9) & move active window to desktop (1-9)
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Cycle through desktops that currently exist (wraps around)
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Go to the next free desktop (reuses an empty fixed one, otherwise creates a new one)
hl.bind(mainMod .. " + ALT + N", hl.dsp.focus({ workspace = "emptynm" }))

-- Send active window to the next free desktop and follow it
hl.bind(mainMod .. " + ALT + SHIFT + N", hl.dsp.window.move({ workspace = "emptynm" }))

-- Scratchpad: a hidden special desktop for apps you keep running out of sight
local scratchpad   = "scratch"
local scratchpadWs = "special:" .. scratchpad

-- Show/hide the scratchpad (nothing happens while it holds no windows)
hl.bind(mainMod .. " + grave", function()
    if hl.get_active_special_workspace() then
        hl.dispatch(hl.dsp.workspace.toggle_special(scratchpad))
        return
    end

    local ws = hl.get_workspace(scratchpadWs)
    if ws and ws.windows > 0 then
        hl.dispatch(hl.dsp.workspace.toggle_special(scratchpad))
    end
end, { description = "Toggle scratchpad" })

-- Park the focused window in the scratchpad without switching to it
hl.bind(mainMod .. " + SHIFT + grave", function()
    if not hl.get_active_window() then
        return
    end
    hl.dispatch(hl.dsp.window.move({ workspace = scratchpadWs, follow = false }))
end, { description = "Send window to scratchpad" })

-- Bring the focused window back to the current desktop
hl.bind(mainMod .. " + CTRL + grave", function()
    local win = hl.get_active_window()
    local ws  = win and win.workspace
    if not ws or not ws.special then
        return
    end

    local mon  = hl.get_active_monitor()
    local dest = mon and mon.active_workspace
    if not dest or dest.special then
        return
    end

    hl.dispatch(hl.dsp.window.move({ workspace = dest.name, follow = false }))

    -- Hide the pad again so the pulled-out window is actually visible
    if hl.get_active_special_workspace() then
        hl.dispatch(hl.dsp.workspace.toggle_special(scratchpad))
    end
end, { description = "Pull window out of scratchpad" })

-- Mouse move/resize fallback (Super + Left/Right drag)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume & brightness keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })
