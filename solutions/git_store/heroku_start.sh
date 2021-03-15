#!/bin/sh
# Let rocket bind heroku port
export ROCKET_PORT="${PORT}"

if [ "${ENABLE_ADMIN}" == "true" ]; then
  echo "ENABLE ADMIN"
  export ADMIN_TOKEN="${GEN_ADMIN_TOKEN}"
else
  echo "DISABLE ADMIN"
  unset ADMIN_TOKEN
fi

warn () {
    echo "$0:" "$@" >&2
}
die () {
    rc=$1
    shift
    warn "$@"
    exit $rc
}

# Below flags depends on Project enviroments, won't allow modify by client
export BAK_START_TIME="$(date +'%Y-%m-%d_%H-%M')"
/git_backup.sh init || die 1 "Failed to init git_backup"

/git_backup.sh restore_db || die 2 "Failed to restore database" 
echo "Restore DB OK"


unset DATABASE_URL
export DATA_FOLDER="/data"
mkdir -p "/data/attachments"
mkdir -p "/data/icon_cache"
cd /
/bin/sh /start.sh &

# Restore other things.
/git_backup.sh restore_file || die 3 "Failed to restore files"
echo "Restore Files OK"

# TODO: Watching DB is not working yet
# /inotify_backup_db.sh &
# /inotify_backup_file.sh &

if [ "${POLLING_BACKUP}" == "true" ]; then
  /polling_backup.sh
else
  sleep 100d
fi
