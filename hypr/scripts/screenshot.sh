#!/bin/bash
ACTION=$1
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
FILENAME="$SAVE_DIR/Screenshot_${TIMESTAMP}.png"

if [ "$ACTION" = "save" ]; then
    grim -g "$(slurp)" "$FILENAME" && wl-copy < "$FILENAME" && notify-send -a "Screenshot" "Screenshot Saved & Copied" "$FILENAME"
elif [ "$ACTION" = "edit" ]; then
    grim -g "$(slurp)" - | swappy -f -
fi
