#!/usr/bin/env bash

set -euo pipefail

DATA_DISK=/dev/disk/azure/scsi1/lun10
MOUNT_POINT=/data
APP_DIR=/data/app
APP_USER="${1:-${SUDO_USER:-}}"

if [[ ! -e "$DATA_DISK" ]]; then
    echo "Data disk for LUN 10 was not found at $DATA_DISK" >&2
    exit 1
fi

mkdir -p "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
    if ! blkid "$DATA_DISK" >/dev/null 2>&1; then
        mkfs.ext4 "$DATA_DISK"
    fi
    mount "$DATA_DISK" "$MOUNT_POINT"
fi

UUID="$(blkid -s UUID -o value "$DATA_DISK")"
FSTAB_ENTRY="UUID=$UUID $MOUNT_POINT ext4 defaults,nofail 0 2"
if ! grep -qF "UUID=$UUID $MOUNT_POINT " /etc/fstab; then
    printf '%s\n' "$FSTAB_ENTRY" >> /etc/fstab
fi

mkdir -p "$APP_DIR/todolist/static/files"
if [[ -n "$APP_USER" ]]; then
    chown -R "$APP_USER:$APP_USER" "$APP_DIR"
fi

mountpoint -q "$MOUNT_POINT"
test -d "$APP_DIR"
test -w "$APP_DIR/todolist/static/files"
echo "$MOUNT_POINT is mounted and $APP_DIR is ready."
