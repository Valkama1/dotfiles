#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

# We use SUDO_USER to ensure the hook runs spicetify as your normal user, not as root!
REAL_USER=${SUDO_USER:-$(whoami)}

echo "Creating Spicetify pacman hook..."
mkdir -p /etc/pacman.d/hooks

cat << EOF > /etc/pacman.d/hooks/spicetify.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = spotify

[Action]
Description = Re-applying Spicetify patches after Spotify update...
When = PostTransaction
Exec = /bin/su $REAL_USER -c "spicetify backup apply"
EOF

echo "Done! Spicetify will now automatically patch Spotify every time you update it."
