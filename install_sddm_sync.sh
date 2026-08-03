#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo ~$REAL_USER)

echo "1. Creating sync script at /usr/local/bin/sddm-wallpaper-sync.sh..."
cat << EOF > /usr/local/bin/sddm-wallpaper-sync.sh
#!/bin/bash
# 1. Update the wallpaper
WALLPAPER_SRC=\$(grep -oP '"dark": "\K[^"]+' $REAL_HOME/.cache/noctalia/wallpapers.json | head -1)

if [ -n "\$WALLPAPER_SRC" ] && [ -f "\$WALLPAPER_SRC" ]; then
    cp "\$WALLPAPER_SRC" /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/noctalia_wallpaper.jpg
    chmod 644 /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/noctalia_wallpaper.jpg
fi

# 2. Extract and apply Noctalia colors
COLOR_FILE="$REAL_HOME/.config/noctalia/colors.json"
if [ -f "\$COLOR_FILE" ]; then
    PRIMARY=\$(grep '"mPrimary"' "\$COLOR_FILE" | cut -d'"' -f4)
    ONPRIMARY=\$(grep '"mOnPrimary"' "\$COLOR_FILE" | cut -d'"' -f4)
    SURFACE=\$(grep '"mSurface"' "\$COLOR_FILE" | cut -d'"' -f4)
    ERRORCOLOR=\$(grep '"mError"' "\$COLOR_FILE" | cut -d'"' -f4)

    ACTIVE_THEME=\$(grep -oP '^ConfigFile=\K.*' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop)
    CONFIG_FILE="/usr/share/sddm/themes/sddm-astronaut-theme/\$ACTIVE_THEME"
    
    # Enable automatic dynamic scaling for any monitor resolution
    sed -i 's|^ScreenWidth=.*|ScreenWidth=""|g' "\$CONFIG_FILE"
    sed -i 's|^ScreenHeight=.*|ScreenHeight=""|g' "\$CONFIG_FILE"

    # Update Background Image
    sed -i "s|^Background=.*|Background=\"Backgrounds/noctalia_wallpaper.jpg\"|g" "\$CONFIG_FILE"
    sed -i "s|^BackgroundPlaceholder=.*|BackgroundPlaceholder=\"Backgrounds/noctalia_wallpaper.jpg\"|g" "\$CONFIG_FILE"
    
    # Text, Icons, Highlights -> PRIMARY
    sed -i "s|^HeaderTextColor=.*|HeaderTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^DateTextColor=.*|DateTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^TimeTextColor=.*|TimeTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^LoginFieldTextColor=.*|LoginFieldTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^PasswordFieldTextColor=.*|PasswordFieldTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^UserIconColor=.*|UserIconColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^PasswordIconColor=.*|PasswordIconColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^SystemButtonsIconsColor=.*|SystemButtonsIconsColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^SessionButtonTextColor=.*|SessionButtonTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^VirtualKeyboardButtonTextColor=.*|VirtualKeyboardButtonTextColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^LoginButtonBackgroundColor=.*|LoginButtonBackgroundColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HighlightBackgroundColor=.*|HighlightBackgroundColor=\"\$PRIMARY\"|g" "\$CONFIG_FILE"

    # Hover States -> White/OnPrimary
    sed -i "s|^HoverUserIconColor=.*|HoverUserIconColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HoverPasswordIconColor=.*|HoverPasswordIconColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HoverSystemButtonsIconsColor=.*|HoverSystemButtonsIconsColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HoverSessionButtonTextColor=.*|HoverSessionButtonTextColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HoverVirtualKeyboardButtonTextColor=.*|HoverVirtualKeyboardButtonTextColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^LoginButtonTextColor=.*|LoginButtonTextColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^HighlightTextColor=.*|HighlightTextColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    
    # Form Background -> SURFACE
    sed -i "s|^FormBackgroundColor=.*|FormBackgroundColor=\"\$SURFACE\"|g" "\$CONFIG_FILE"
    sed -i "s|^BackgroundColor=.*|BackgroundColor=\"\$SURFACE\"|g" "\$CONFIG_FILE"
    sed -i "s|^DimBackgroundColor=.*|DimBackgroundColor=\"\$SURFACE\"|g" "\$CONFIG_FILE"
    
    # Input Backgrounds -> ONPRIMARY
    sed -i "s|^LoginFieldBackgroundColor=.*|LoginFieldBackgroundColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    sed -i "s|^PasswordFieldBackgroundColor=.*|PasswordFieldBackgroundColor=\"\$ONPRIMARY\"|g" "\$CONFIG_FILE"
    
    # Warnings -> ERRORCOLOR
    sed -i "s|^WarningColor=.*|WarningColor=\"\$ERRORCOLOR\"|g" "\$CONFIG_FILE"
fi
EOF
chmod +x /usr/local/bin/sddm-wallpaper-sync.sh

echo "2. Updating SDDM Astronaut Theme configuration..."
CONFIG_FILE="/usr/share/sddm/themes/sddm-astronaut-theme/Themes/hyprland_kath.conf"
if [ -f "$CONFIG_FILE" ]; then
    sed -i 's|^Background=.*|Background="Backgrounds/noctalia_wallpaper.jpg"|g' "$CONFIG_FILE"
    sed -i 's|^BackgroundPlaceholder=.*|BackgroundPlaceholder="Backgrounds/noctalia_wallpaper.jpg"|g' "$CONFIG_FILE"
else
    echo "Warning: SDDM astronaut theme config not found at $CONFIG_FILE"
fi

echo "3. Creating systemd path watcher..."
cat << EOF > /etc/systemd/system/sddm-wallpaper-sync.path
[Unit]
Description=Watch for Noctalia wallpaper changes

[Path]
PathModified=$REAL_HOME/.cache/noctalia/wallpapers.json

[Install]
WantedBy=multi-user.target
EOF

echo "4. Creating systemd service..."
cat << EOF > /etc/systemd/system/sddm-wallpaper-sync.service
[Unit]
Description=Sync Noctalia wallpaper to SDDM

[Service]
Type=oneshot
ExecStart=/usr/local/bin/sddm-wallpaper-sync.sh
EOF

echo "5. Enabling and starting the watcher..."
systemctl daemon-reload
systemctl enable --now sddm-wallpaper-sync.path

# Trigger an initial sync right now!
systemctl start sddm-wallpaper-sync.service

echo ""
echo "Done! Your SDDM login screen is now perfectly synced with your Noctalia wallpapers!"
