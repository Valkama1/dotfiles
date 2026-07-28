#!/bin/bash

# Must be run with sudo to fix Spotify folder permissions
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo ~$REAL_USER)

echo "1. Granting Spotify folder permissions so Spicetify can patch it..."
chmod a+wr /opt/spotify
chmod a+wr /opt/spotify/Apps -R

echo "2. Installing/Updating Spicetify for user $REAL_USER..."
su $REAL_USER -c "curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh"
# Also install Spicetify Marketplace for extra tweaks!
su $REAL_USER -c "curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh"

echo "3. Downloading the Comfy theme..."
su $REAL_USER -c "rm -rf $REAL_HOME/.config/spicetify/Themes/Comfy"
su $REAL_USER -c "git clone --depth=1 https://github.com/Comfy-Themes/Spicetify $REAL_HOME/.config/spicetify/Themes/Comfy"

echo "4. Configuring Spicetify..."
# Setup Spicetify config file by running it once
su $REAL_USER -c "$REAL_HOME/.spicetify/spicetify -c $REAL_HOME/.config/spicetify/config-xpui.ini"

# Set the theme and color scheme
su $REAL_USER -c "$REAL_HOME/.spicetify/spicetify config current_theme Comfy color_scheme noctalia inject_css 1 replace_colors 1 overwrite_assets 1"

echo "5. Applying Spicetify..."
su $REAL_USER -c "$REAL_HOME/.spicetify/spicetify backup apply"

echo "6. Hacking Noctalia to enable seamless CSS hot-reloading..."
sed -i 's/`spicetify -q apply --no-restart`/`spicetify watch -s \\& sleep 2 \\&\\& pkill -f \\"spicetify watch\\"`/g' /etc/xdg/quickshell/noctalia-shell/Services/Theming/TemplateRegistry.qml

# Restart noctalia to apply the new template hook
pkill -f "noctalia-shell"

echo ""
echo "Done! Spicetify has been completely reinstalled and configured for perfect dynamic hot-reloading without restarts!"
