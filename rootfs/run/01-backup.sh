
function main {
  await "$BACKUP_SOURCE" 10 \
    || fail 'backup source not available'

  await "$BACKUP_TARGET" 10 \
    || fail 'backup target not available'

  mkdir -p /mnt
  mount "$BACKUP_TARGET" /mnt \
    || fail 'could not mount target device'

  if [ -e "/mnt/$BACKUP_FILE.renew" ]; then
    log "starting backup of $BACKUP_SOURCE to $BACKUP_TARGET ($BACKUP_FILE)"
    rm -f "/mnt/$BACKUP_FILE.renew"
    dd if="$BACKUP_SOURCE" of="/mnt/$BACKUP_FILE"
  fi

  umount /mnt
}

function await {
  file="$1"
  timeout="$2"

  while [ ! -e "$file" ]; do
    sleep 1
    timeout=$((timeout - 1))
    if [ $timeout -lt 0 ]; then
      return 1
    fi
  done
}

function fail {
  log "$1"
  exit 1
}
