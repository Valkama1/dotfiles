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
# Extract the active wallpaper from Noctalia's JSON cache using grep
WALLPAPER_SRC=\$(grep -oP '"dark": "\K[^"]+' $REAL_HOME/.cache/noctalia/wallpapers.json | head -1)

if [ -n "\$WALLPAPER_SRC" ] && [ -f "\$WALLPAPER_SRC" ]; then
    cp "\$WALLPAPER_SRC" /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/noctalia_wallpaper.jpg
    chmod 644 /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/noctalia_wallpaper.jpg
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
