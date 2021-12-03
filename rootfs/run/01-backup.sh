
function main {
  local source="$BACKUP_SOURCE"
  local target="$BACKUP_TARGET"
  local file="$BACKUP_FILE"

  await "$source" 10 \
    || die "backup source ($source) not available"

  echo "backup source $source ready"

  await "$target" 10 \
    || die "backup target ($target) not available"

  echo "backup target $target ready"

  mkdir -p /mnt
  mount "$target" /mnt \
    || die 'could not mount target device'

  if [ -e "/mnt/$file.renew" ]; then
    echo "starting backup of $source to $target ($file)"
    rm -f "/mnt/$file.renew"
    dd if="$source" of="/mnt/$file" bs=4M conv=fsync
  else
    echo 'renew flag file does not exist, skipping backup'
  fi

  umount /mnt
}

function await {
  local file="$1"
  local timeout="$2"

  if [ -z "$file" ]; then
    return 1
  fi

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
