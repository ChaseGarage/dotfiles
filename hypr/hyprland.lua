-- #######################################################################################

-- Tyler's Hyprland Config

-- # #######################################################################################

-- source = ~/.config/hypr/bindings.conf -> requires manual conversion
local bindings = require("bindings")
-- TODO: convert ~/.config/hypr/bindings.conf to .lua and use require()

-- source = ~/.config/hypr/looknfeel.conf -> requires manual conversion
local looknfeel = require("looknfeel")
-- TODO: convert ~/.config/hypr/looknfeel.conf to .lua and use require()

-- source = ~/.config/hypr/monitors.conf -> requires manual conversion
local monitors = require("monitors")
-- TODO: convert ~/.config/hypr/monitors.conf to .lua and use require()

-- source = ~/.config/hypr/input.conf -> requires manual conversion
local input = require("input")
-- TODO: convert ~/.config/hypr/input.conf to .lua and use require()

-- source = ~/.config/custom/current/theme/hyprland.conf -> requires manual conversion
--local hyprland = require("custom.current.theme.hyprland")
-- TODO: convert ~/.config/custom/current/theme/hyprland.conf to .lua and use require()

--################

--## AUTOSTART ###

--################

-- Autostart necessary processes (like notifications daemons, status bars, etc.)

-- Export environment-variables for QT applications

--exec-once = systemctl --user import-environment QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE

--exec-once = dbus-update-activation-environment --systemd QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE

-- Slow app launch fix -- set systemd vars

--############################

--## ENVIRONMENT VARIABLES ###

--############################

-- See https://wiki.hypr.land/Configuring/Environment-variables/

--QT Scaling passthrough

--env = QT_SCALE_FACTOR_ROUNDING_POLICY,PassThrough

hl.env("XCURSOR_SIZE", 24)

hl.env("HYPRCURSOR_SIZE", 24)

-- Force all apps to use Wayland

hl.env("GDK_BACKEND", "wayland,x11,*")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")

hl.env("QT_STYLE_OVERRIDE", "kvantum")

hl.env("SDL_VIDEODRIVER", "wayland")

hl.env("MOZ_ENABLE_WAYLAND", 1)

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

hl.env("OZONE_PLATFORM", "wayland")

hl.env("XDG_SESSION_TYPE", "wayland")

-- Allow better support for screen sharing (Google Meet, Discord, etc)

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")

hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.config({
	xwayland = {
		force_zero_scaling = true,
	},
})

--env = LIBVA_DRIVER_NAME,nvidia

--env = __GLX_VENDOR_LIBRARY_NAME,nvidia

--##################

--## PERMISSIONS ###

--##################

-- See https://wiki.hypr.land/Configuring/Permissions/

-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly

-- for security reasons

-- ecosystem {

--   enforce_permissions = 1

-- }

-- permission = /usr/(bin|local/bin)/grim, screencopy, allow

-- permission = /usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland, screencopy, allow

-- permission = /usr/(bin|local/bin)/hyprpm, plugin, allow

--#############################

--## WINDOWS AND WORKSPACES ###

--#############################

-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more

-- See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

hl.config({
	general = {
		resize_on_border = true,
	},
})

hl.window_rule({
	name = "suppress-maximize-events",
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Hyprland-run windowrule

hl.window_rule({
	name = "move-hyprland-run",
	match = {
		class = "hyprland-run",
	},
	move = { 20, "monitor_h-120" },
	float = true,
})

-- Autostart
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("swaync")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpm reload")
	hl.exec_cmd("swaybg -i/home/tyler/.config/custom/current/background -m fill")
	hl.exec_cmd("hyprsunset")
	hl.exec_cmd("systemctl --user import-environment $(env| cut -d'=' -f 1)")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("udiskie --no-tray")
end)
