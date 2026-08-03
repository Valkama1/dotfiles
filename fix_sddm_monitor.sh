#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# Turn off the secondary monitor in the SDDM X11 setup script
# We try multiple common Xorg naming variations just to be absolutely safe
echo 'xrandr --output HDMI-A-2 --off 2>/dev/null' >> /usr/share/sddm/scripts/Xsetup
echo 'xrandr --output HDMI-2 --off 2>/dev/null' >> /usr/share/sddm/scripts/Xsetup
echo 'xrandr --output HDMI2 --off 2>/dev/null' >> /usr/share/sddm/scripts/Xsetup

echo "Done! The secondary HDMI monitor will now stay off while SDDM is running, and turn on when Hyprland starts!"
