
function main {
  await "$BACKUP_SOURCE" 10 \
    || perror 2 'backup source not available'

  await "$BACKUP_TARGET" 10 \
    || perror 3 'backup target not available'

  mkdir -p /mnt
  mount "$BACKUP_TARGET" /mnt || return 4

  if [ ! -e "/mnt/$BACKUP_FILE" ]; then
    dd if="$BACKUP_SRCDEV" of="/mnt/$BACKUP_FILE"
  fi

  umount /mnt
}
