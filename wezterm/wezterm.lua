--- wezterm.lua
--- __      __      _
--- \ \    / /__ __| |_ ___ _ _ _ __
---  \ \/\/ / -_)_ /  _/ -_) '_| '  \
---   \_/\_/\___/__|\__\___|_| |_|_|_|
---
--- My Wezterm config file

local wezterm = require 'wezterm'
local mux = wezterm.mux

-- Plugin for WezTerm
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
local workspace_switcher = wezterm.plugin.require("https://github.com/MLFlexer/smart_workspace_switcher.wezterm")

local is_windows = wezterm.target_triple:find("windows") ~= nil

local default_cwd = is_windows
    and "C:/Users/a5134005/hungquangnguyen/FSP"
    or wezterm.home_dir

-- Single source of truth for the Nushell binary (0.114.1)
local nu_prog = is_windows
    and "C:\\Users\\a5134005\\AppData\\Local\\Programs\\nu\\bin\\nu.exe"
    or "nu"

local config = {}

if wezterm.config_builder then
    config = wezterm.config_builder()
end

wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

-- Define custom color schemes
config.color_schemes = {
    ["tokyonight_moon"] = {
        -- Basic colors
        foreground = "#c8d3f5",
        background = "#222436",

        -- Cursor colors
        cursor_bg = "#c8d3f5",
        cursor_border = "#c8d3f5",
        cursor_fg = "#222436",

        -- Selection colors
        selection_bg = "#2d3f76",
        selection_fg = "#c8d3f5",

        -- Quick Select overlay readability (labels = amber chips on dark)
        quick_select_label_fg = { Color = "#222436" },
        quick_select_label_bg = { Color = "#ffc777" },
        quick_select_match_fg = { Color = "#c8d3f5" },
        quick_select_match_bg = { Color = "#2d3f76" },

        -- UI element colors
        split = "#82aaff",
        compose_cursor = "#ff966c",
        scrollbar_thumb = "#2f334d",

        -- ANSI colors
        brights = { "#444a73", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#c8d3f5" },
        ansi = { "#1b1d2b", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#828bb8" },

        -- Tab bar colors
        tab_bar = {
            inactive_tab_edge = "#1e2030",
            background = "#222436",
            active_tab = {
                fg_color = "#1e2030",
                bg_color = "#82aaff",
            },
            inactive_tab = {
                fg_color = "#545c7e",
                bg_color = "#181825",
            },
            inactive_tab_hover = {
                fg_color = "#82aaff",
                bg_color = "#2f334d",
            },
            new_tab_hover = {
                fg_color = "#82aaff",
                bg_color = "#181825",
                intensity = "Bold",
            },
            new_tab = {
                fg_color = "#82aaff",
                bg_color = "#222436",
            },
        },
    },
}

-- Set the active color scheme
config.color_scheme = "tokyonight_moon"
-- config.window_background_opacity = 0.5
-- config.macos_window_background_blur = 70
config.window_decorations = "RESIZE"
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000

-- Enable Scroll bar
config.enable_scroll_bar = true

-- Tab bar
config.use_fancy_tab_bar = false
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
config.tab_and_split_indices_are_zero_based = true

-- Dim inactive panes
config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8
}

-- Rendering front end: WebGPU (wgpu -> Direct3D 12 on Windows).
-- The old OpenGL front end risked falling back to the bundled Mesa llvmpipe
-- (software rasterizer) on this Intel Iris Xe laptop; WebGPU + explicit
-- hardware selection keeps everything on the real GPU.
if is_windows then
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"
    config.webgpu_force_fallback_adapter = false
end

-- Frame pacing: repaints capped at display rate, calm animation clock
config.animation_fps = 10
config.max_fps = 120
config.cursor_blink_rate = 0 -- in milliseconds
config.check_for_updates = false

-- Font settings
-- 12.0 pt matches the Windows Terminal profile exactly (it used the 12 pt
-- default); at 11.0 pt glyphs were ~8% smaller, which is what made the
-- strokes look thin next to WT.
config.font = wezterm.font("CaskaydiaCove Nerd Font")
config.font_size = 12.0

-- Kill the cross-monitor DPI resize feedback loop (wezterm/wezterm#7883,
-- still UNMERGED as of this nightly 20260829-162155-5140f989):
-- while a window is being DRAGGED across a DPI boundary, resize() sees
-- dpi != last dpi even during live resizing, falls into scaling_changed(),
-- and calls set_inner_size()/SetWindowPos mid-drag to "preserve rows+cols".
-- That fights both the user drag and Windows' DPI-suggested rect: the
-- window oscillates between the two geometries, and every oscillation
-- re-reports a new pane size, so the herdr client (cols 212x55 -> 136x37
-- storm in %APPDATA%/herdr/herdr-server.log) resizes all ConPTY panes and
-- each omp TUI re-renders -> visible char/UI toggling for minutes.
-- WezTerm reads effective DPI via config.dpi before the OS value
-- (window/src/os/windows/window.rs get_effective_dpi), so pinning it here
-- makes every Resized event carry a constant dpi -> resize() always takes
-- the fast live-resize path -> wezterm never calls SetWindowPos -> no loop.
-- 96 = this laptop's native scale (100%); text now stays sharp and
-- physically smaller on the high-DPI external display instead of the OS
-- rescaling it. Remove this line once a nightly ships #7883.
if is_windows then
    config.dpi = 96
end

if is_windows then
    config.enable_wayland = false
end

-- Define the launch menu with various shell options
-- Common paths and addresses
local coder_base_url = "http://coder.hcmflexbuild001.rvc.renesas.com/"
local rx_coder_sing_url = "http://10.230.228.121:8080/"
local rx_coder_mini_url = "http://coder.codermini1.rvc.renesas.com/"

-- Helper function to create a coder login entry
local function coder_login_entry(label, url)
    return {
        label = "Login to " .. label,
        args = { "coder", "login", url },
    }
end
config.launch_menu = {
    {
        label = 'Nushell',
        args = { nu_prog },
        cwd = default_cwd
    },
    {
        -- Herdr workspace manager; its panes start in Nushell
        -- (%APPDATA%/herdr/config.toml -> [terminal] default_shell = nu.exe).
        label = 'Herdr (Nushell)',
        args = { 'C:\\Users\\a5134005\\AppData\\Local\\Programs\\Herdr\\bin\\herdr.exe' },
        cwd = default_cwd,
    },
    {
        label = 'Bash',
        args = { 'bash', '-l' },
        cwd = default_cwd
    },
    {
        label = 'PowerShell',
        args = { 'C:\\Program Files\\PowerShell\\7-preview\\pwsh.exe' },
        cwd = default_cwd
    },
    -- Install package automatically
    {
        label = 'Install package for FSP',
        args = { 'bash', 'C:\\Users\\a5134005\\hungquangnguyen\\FSP\\08_Tutorial\\install_pack_rx.sh' },
    },
    {
        label = "SSH to Pi RX (10.23.9.131)",
        args = { "ssh", "rvc@10.231.9.131" },
    },
    {
        label = "SSH to Coder HCM1 (RXFSP)",
        args = { "ssh", "coder.RXFSP" },
    },
    {
        label = "Coder configure SSH",
        args = { "coder", "config-ssh" },
    },
    -- Coder Logins
    coder_login_entry("RA Coder HCM1", coder_base_url),
    coder_login_entry("RX Coder Sing", rx_coder_sing_url),
    coder_login_entry("RX Coder Mini", rx_coder_mini_url),
    coder_login_entry("Coder configure SSH", rx_coder_mini_url),
}

-- Default terminal startup
-- Nushell 0.114.1 (installed at AppData/Local/Programs/nu)
if is_windows then
    config.default_prog = { nu_prog }
end

-- Set the default directory where WezTerm will start
config.default_cwd = default_cwd

-- Enable focus follows mouse
config.pane_focus_follows_mouse = true
config.hide_mouse_cursor_when_typing = true

-- Configure mouse behavior
--
-- Root cause of the "clipboard wiped by a stray click" bug: the old binding
-- ran CopyTo on EVERY Left-Up event, including plain clicks with no drag.
-- WezTerm then completes/copies the selection state as-is, so a click or a
-- micro-jitter drag over blank cells copies an empty/whitespace string and
-- overwrites the clipboard (wezterm/wezterm#7135). Windows Terminal only
-- touches the clipboard when a release actually selected non-blank text,
-- so every copy path is now gated on the selection contents.
local function copy_if_non_blank_selection(window, pane)
    local text = window:get_selection_text_for_pane(pane)
    if text:match('%S') then
        window:perform_action(wezterm.action.CompleteSelection('ClipboardAndPrimarySelection'), pane)
    end
    -- else: stray click on blank space -> selection stays visible, clipboard untouched
end

config.mouse_bindings = {
    -- Left release after click / drag / double-click (word) / triple-click
    -- (line): copy only real text. Selection is NOT cleared afterwards,
    -- because the Enter key binding pastes it via PrimarySelection.
    { event = { Up = { streak = 1, button = 'Left' } }, action = wezterm.action_callback(copy_if_non_blank_selection) },
    { event = { Up = { streak = 2, button = 'Left' } }, action = wezterm.action_callback(copy_if_non_blank_selection) },
    { event = { Up = { streak = 3, button = 'Left' } }, action = wezterm.action_callback(copy_if_non_blank_selection) },
    {
        event = { Down = { streak = 1, button = 'Right' } },
        action = wezterm.action.PasteFrom('Clipboard'), -- Paste on right click
    },
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = wezterm.action.OpenLinkAtMouseCursor, -- Open link under cursor when Ctrl+Left clicking
    },
}

-- Quick Select Mode (default trigger: CTRL-SHIFT-SPACE)
--
-- Why detection "missed" before: the built-in pattern set only labels
-- structured items (URLs, git sha, IPv4/IPv6, 0xADDR, >=4-digit numbers,
-- unix paths, #colors, uuid, docker digest, diff a/b lines). Plain
-- identifiers, Windows paths, file:line diagnostics, MAC addresses and log
-- timestamps match nothing, so most tokens on screen stay unlabeled.
-- Enhancements:
--   * merge real-world shapes below into the global set (CTRL-SHIFT-SPACE);
--   * CTRL-SHIFT-Q = token mode: label every word/identifier/number;
--   * strip ANSI styling before matching so hint chips stand out on busy
--     colored output (nvim, pwsh, serial logs).
config.quick_select_remove_styling = true

config.quick_select_patterns = {
    -- Windows drive path: C:\dir\file.c, D:/x/y
    '[A-Za-z]:[\\\\/][^\\s"<>|]*',
    -- UNC share: \\\\server\\share\\file.log
    '\\\\\\\\[^\\s"<>/\\\\]+(?:\\\\[^\\s"<>/\\\\]+)*',
    -- File name with known extension, optionally +:line or +:line:col
    -- (compiler/linker diagnostics). Longest extensions first: 'c'/'h' last
    -- so '.config' etc. cannot be cut down to '.c'.
    '[\\w.\\-/\\\\]+\\.(?:hpp|cpp|cc|md|json|toml|yaml|yml|lua|py|rs|sh|bash|zsh|ps1|csv|txt|log|ini|conf|cfg|xml|html|css|js|ts|mk|dts|dtsi|h|c)(?::[0-9]+){0,2}(?![\\w-])',
    -- MAC address
    '(?<![0-9A-Za-z_:-])(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}(?![0-9A-Za-z_:-])',
    -- ISO date-time with time part: 2026-09-02 23:11:00(.123) / T separator
    '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}:[0-9]{2}(?:[.,][0-9]+)?',
    -- Bare clock time: 23:11:00,789
    '(?<![0-9:])[0-9]{2}:[0-9]{2}:[0-9]{2}(?:[.,][0-9]+)?',
    -- Kernel-style uptime stamp: [    0.123456]
    '\\[\\s*[0-9]+\\.[0-9]+\\s*\\]',
    -- Semantic version-ish: 1.2.3 / 2.0.0-rc1 / 3.4.5+build7
    '(?<![0-9])[0-9]+\\.[0-9]+\\.[0-9]+(?:[-+][\\w.]+)?(?![\\w-])',
    -- Hex literal with C integer suffix: 0x1234UL / 0xffu (extends the
    -- built-in 0x... which stops at the suffix)
    '0[xX][0-9a-fA-F]+[uUlL]{0,3}(?![0-9A-Za-z])',
}

-- Key bindings similar to Windows Terminal
config.keys = {
    -- New tab
    { key = "t",          mods = "CTRL|SHIFT", action = wezterm.action.SpawnCommandInNewTab({args = { nu_prog }, cwd = default_cwd})},

    -- Delete one word
    { key = 'Backspace',  mods = 'CTRL',       action = wezterm.action.SendKey { key = 'w', mods = 'CTRL' } },

    -- Show Launcher
    { key = "L",          mods = "CTRL|SHIFT", action = wezterm.action.ShowLauncher },

    -- Close tab
    { key = "w",          mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane { confirm = false } },

    -- Next tab
    { key = "Tab",        mods = "CTRL",       action = wezterm.action.ActivateTabRelative(1) },

    -- Previous tab
    { key = "Tab",        mods = "CTRL|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },

    -- Split pane horizontally/vertically into a new domain
    { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal { domain = "DefaultDomain" } },
    { key = "DownArrow",  mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical { domain = "DefaultDomain" } },

    -- Navigate between panes
    { key = "LeftArrow",  mods = "ALT",        action = wezterm.action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "ALT",        action = wezterm.action.ActivatePaneDirection("Right") },
    { key = "UpArrow",    mods = "ALT",        action = wezterm.action.ActivatePaneDirection("Up") },
    { key = "DownArrow",  mods = "ALT",        action = wezterm.action.ActivatePaneDirection("Down") },

    -- Resize panes
    { key = "LeftArrow",  mods = "CTRL|ALT",   action = wezterm.action.AdjustPaneSize { "Left", 1 } },
    { key = "RightArrow", mods = "CTRL|ALT",   action = wezterm.action.AdjustPaneSize { "Right", 1 } },
    { key = "UpArrow",    mods = "CTRL|ALT",   action = wezterm.action.AdjustPaneSize { "Up", 1 } },
    { key = "DownArrow",  mods = "CTRL|ALT",   action = wezterm.action.AdjustPaneSize { "Down", 1 } },

    -- Copy and Paste
    { key = "c",          mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
    { key = "v",          mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },

    -- Search
    { key = "f",          mods = "CTRL|SHIFT", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },

    -- Quick Select token mode: label words / identifiers / numbers
    -- (anything the structured CTRL-SHIFT-SPACE set misses)
    {
        key = 'q',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.QuickSelectArgs {
            label = 'copy word',
            patterns = {
                -- identifier, incl. dotted/slashed parts: foo_bar, src/main.c, ver-1.2
                '[A-Za-z_][A-Za-z0-9_]*(?:[.\\\\/-][A-Za-z0-9_]+)*',
                -- plain number / dotted number: 42, 3.14159
                '[0-9]+(?:\\.[0-9]+)*',
            },
        },
    },

    -- Switch Workspace
    { key = "s",          mods = "ALT",        action = workspace_switcher.switch_workspace(), } }

-- Create tab activation keys in a loop (1-7)
for i = 1, 7 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "ALT",
        action = wezterm.action.ActivateTab(i - 1)
    })
end

-- NOTE: Set up tabline for WezTerm
tabline.setup({
    options = {
        icons_enabled = true,
        theme = 'Catppuccin Mocha',
        color_overrides = {},
        section_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider,
        },
        component_separators = {
            left = wezterm.nerdfonts.pl_left_soft_divider,
            right = wezterm.nerdfonts.pl_right_soft_divider,
        },
        tab_separators = {
            left = wezterm.nerdfonts.pl_left_hard_divider,
            right = wezterm.nerdfonts.pl_right_hard_divider,
        },
    },
    sections = {
        tabline_a = { 'mode' },
        tabline_b = { 'workspace' },
        tabline_c = { ' ' },
        tab_active = {
            'index',
            { 'parent', padding = 0 },
            '/',
            { 'cwd',    padding = { left = 0, right = 1 } },
            { 'zoomed', padding = 0 },
        },
        tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
        tabline_x = { 'ram', 'cpu' },
        tabline_y = { 'datetime', 'battery' },
        tabline_z = { 'hungquangnguyen' },
    },
    extensions = {},
})

-- Config format for smart switch workspace.
workspace_switcher.workspace_formatter = function(label)
    return wezterm.format({
        { Attribute = { Italic = true } },
        { Foreground = { Color = "#c3e88d" } },
        { Background = { Color = "#1b1d2b" } },
        { Text = "󱂬: " .. label },
    })
end

-- Load extension configuration
tabline.apply_to_config(config)
workspace_switcher.apply_to_config(config)

return config
