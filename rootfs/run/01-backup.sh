
function main {
  backup "$BACKUP_SOURCE" "$BACKUP_TARGET" "$BACKUP_FILE"
}

function backup {
  local source="$1"
  local target="$2"
  local file="$3"

  await "$source" 10 \
    || die 'backup source not available'

  await "$target" 10 \
    || die 'backup target not available'

  mkdir -p /mnt
  mount "$target" /mnt \
    || die 'could not mount target device'

  if [ -e "/mnt/$file.renew" ]; then
    echo "starting backup of $source to $target ($file)"
    rm -f "/mnt/$file.renew"
    echo if="$source" of="/mnt/$file"
  fi

  umount /mnt
}

function await {
  local file="$1"
  local timeout="$2"

  while [ ! -e "$file" ]; do
    sleep 1
    timeout=$((timeout - 1))
    if [ $timeout -lt 0 ]; then
      return 1
    fi
  done
}

function die {
  echo "$1"
  exit 1
}
