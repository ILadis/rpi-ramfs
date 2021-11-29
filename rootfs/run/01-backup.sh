
function main {
  await "$BACKUP_SOURCE" 10 \
    || perror 2 'backup source not available'

  await "$BACKUP_TARGET" 10 \
    || perror 3 'backup target not available'

  mkdir -p /mnt
  mount "$BACKUP_TARGET" /mnt \
    || perror 4 'could not mount target device'

  if [ ! -e "/mnt/$BACKUP_FILE" ]; then
    dd if="$BACKUP_SOURCE" of="/mnt/$BACKUP_FILE"
  fi

  umount /mnt
}

function await {
  file="$1"
  timeout="$2"

  until [ -e "$file" ]; do
    sleep 1
    timeout=$((timeout - 1))
    if [ $timeout -lt 0 ]; then
      return 1
    fi
  done

  return 0
}

function perror {
  echo $2
  exit $1
}
