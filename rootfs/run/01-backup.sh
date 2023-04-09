
function main {
  local source=''; source=$(fswait "$BACKUP_SOURCE" 10) \
    || die "backup source ($BACKUP_SOURCE) not available"

  echo "backup source $source ready"

  local target=''; target=$(fswait "$BACKUP_TARGET" 10) \
    || die "backup target ($BACKUP_TARGET) not available"

  echo "backup target $target ready"

  mkdir -p /mnt
  mount "$target" /mnt \
    || die 'could not mount target device'

  local file="$BACKUP_FILE"

  if [ -e "/mnt/$file.renew" ]; then
    echo "starting backup of $source to $target ($file)"
    rm -f "/mnt/$file.renew"
    dd if="$source" of="/mnt/$file" bs=4M conv=fsync
  else
    echo 'renew flag file does not exist, skipping backup'
  fi

  umount /mnt
}

function fswait {
  local query="$1"
  local timeout="$2"

  if [ -z "$query" ]; then
    return 1
  fi

  local value=$(echo "$query" | cut -d'=' -f2)
  if [ -z "$value" ]; then
    return 1
  fi

  while [ $timeout -gt 0 ]; do
    local device=''

    case "$query" in
      UUID=*)   device=$(findfs "UUID=$value") ;;
      DEVICE=*) device=$(test -e "$value" && echo "$value") ;;
    esac

    if [ -n "$device" ]; then
      echo "$device"
      return 0
    fi

    sleep 1
    timeout=$((timeout - 1))
  done

  return 1
}

function die {
  echo "$1"
  exit 1
}
