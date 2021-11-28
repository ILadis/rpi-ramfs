
function check {
  echo "waiting for target device $BACKUP_DEV"
  await "$BACKUP_DEV" 10 || exit 1

  mkdir -p /mnt/target
  mount "$BACKUP_DEV" /mnt/target

  BACKUP_DATE=0

  if [ -f "$BACKUP_FILE" ]; then
    BACKUP_DATE=$(date -r "$BACKUP_FILE" +'%s')
  fi

  echo "last backup date: $(date --date=@$BACKUP_DATE)"
}

function main {
  echo "running main!"
  check
}
