These are my dotfiles for Hyprland. Specifically I'm running CachyOS but it should not matter. This is a Omarchy like config with some scripts pretty much stolen right from Omarchy. This is not a complete or stable project. This is just my repository for my own dotfiles. There are some settings in here that are specific to my setup. monitors.conf needs to be amended for your specific usecase

Waybar config is based on https://github.com/HANCORE-linux/waybar-themes/tree/main
Rofi config is based on https://github.com/adi1090x/rofi

Dependencies:
btop
xdg-desktop-portal
swaybg
polkit-gnome (or use a different one and change the exec-once line in hyprland.conf)
hyprshot
slurp
satty
hypridle
hyprlock
ttf-jetbrains-mono-nerd
fastfetch
waybar

AUR Dependencies:
waybar-module-pacman-updates-git
yaru-icon-theme

hyprpm Dependencies:
hyprexpo


Theming:
Omarchy themes can be used but you need to add colors.rasi rofi.rasi and waybar.css needs to define accent and border colors. Every rofi.rasi file is the same so you can just copy it. There is a python script that will automatically create colors.rasi for any theme folder that does not have one by pulling colors from the walker.css that is in every Omarchy theme.

