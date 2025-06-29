#!/bin/bash

# Mounts iPhone to directory
IPHONE_STATUS="/var/lib/iphone/connection.status"
MOUNT_POINT="$HOME/mnt/iPhone"

while true; do
    inotifywait -e close_write "$IPHONE_STATUS" >/dev/null 2>&1
    if [[ "$(cat "$IPHONE_STATUS")" == "1" ]]; then
        mkdir -p "$MOUNT_POINT"
        /usr/bin/sleep 2
        /usr/bin/ifuse "$MOUNT_POINT" # Access Camera Photos and Videos
    elif [[ "$(cat "$IPHONE_STATUS")" == "0" ]]; then
        /usr/bin/fusermount -u "$MOUNT_POINT"
        rmdir "$MOUNT_POINT"
    fi
done
