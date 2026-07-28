#!/bin/bash
ACTION=$1
STATE=$2

# ACTION can be 'next' or 'prev'
# STATE can be 'press' or 'release'

if [ "$STATE" = "press" ]; then
    date +%s%3N > "/tmp/media_key_${ACTION}_time"
    touch "/tmp/media_key_${ACTION}_down"
    (
        sleep 0.4
        while [ -f "/tmp/media_key_${ACTION}_down" ]; do
            if [ "$ACTION" = "next" ]; then
                playerctl position 5+
            else
                playerctl position 5-
            fi
            sleep 0.1
        done
    ) &
elif [ "$STATE" = "release" ]; then
    rm -f "/tmp/media_key_${ACTION}_down"
    if [ -f "/tmp/media_key_${ACTION}_time" ]; then
        PRESS_TIME=$(cat "/tmp/media_key_${ACTION}_time")
        RELEASE_TIME=$(date +%s%3N)
        DIFF=$((RELEASE_TIME - PRESS_TIME))
        if [ $DIFF -lt 400 ]; then
            if [ "$ACTION" = "next" ]; then
                playerctl next
            else
                playerctl previous
            fi
        fi
        rm -f "/tmp/media_key_${ACTION}_time"
    fi
fi
