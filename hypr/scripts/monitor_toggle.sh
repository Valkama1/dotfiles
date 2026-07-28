#!/bin/bash
# Check if TV is active
TV_ACTIVE=$(hyprctl monitors -j | grep -q "HDMI-A-1" && echo 1 || echo 0)

if [ "$TV_ACTIVE" = "1" ]; then
    # Switch to Gaming Mode
    echo "gaming" > ~/.config/hypr/monitor_state
    
    # 1. Enable Gaming Monitors
    hyprctl eval 'hl.monitor({ output = "DP-2", mode = "2560x1440@240", position = "auto", scale = "auto", disabled = false })'
    hyprctl eval 'hl.monitor({ output = "HDMI-A-2", mode = "2560x1440@144", position = "0x-550", scale = 1, transform = 1, disabled = false })'
    sleep 0.2
    hyprctl dispatch dpms on DP-2
    hyprctl dispatch dpms on HDMI-A-2
    
    # 2. Disable TV
    hyprctl dispatch dpms off HDMI-A-1
    sleep 0.2
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", disabled = true })'
    
    notify-send -a "Monitors" "Switched to Gaming Setup" "DP-2 and HDMI-A-2 are active."
else
    # Switch to TV Mode
    echo "tv" > ~/.config/hypr/monitor_state
    
    # 1. Enable TV
    hyprctl eval 'hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "auto", scale = 1, disabled = false })'
    sleep 0.2
    hyprctl dispatch dpms on HDMI-A-1
    
    # 2. Disable Gaming Monitors
    hyprctl dispatch dpms off DP-2
    hyprctl dispatch dpms off HDMI-A-2
    sleep 0.2
    hyprctl eval 'hl.monitor({ output = "DP-2", disabled = true })'
    hyprctl eval 'hl.monitor({ output = "HDMI-A-2", disabled = true })'
    
    notify-send -a "Monitors" "Switched to Couch Setup (TV)" "HDMI-A-1 is active."
fi
