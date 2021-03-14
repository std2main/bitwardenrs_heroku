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
export BACKUP_SESSION="$(date +'%Y-%m-%d_%H-%M')"
/git_backup.sh init || die 1 "Failed to init git_backup"

# Restore things required when bitwarden_rs starting
if [ "${DATABASE_URL}" == "/db.sqlite3" ]; then
  echo "Using sqlite3"
else
  die 127 "DATABASE_URL is modified to ${DATABASE_URL}"
fi

export RSA_KEY_FILENAME="${BACKUP_DB_REPO}/rsa_key"
# Default to store things in DB_REPO, admin modified config will be their.

/git_backup.sh restore_db || die 2 "Failed to restore database" 
echo "Restore DB OK"

# TODO: Watching DB is not working yet
/inotify_backup_db.sh &

# Disable log to not spam heroku log.
# May store to local and even in repo when needed.
/bin/sh /start.sh &

# Restore other things.
/git_backup.sh restore_file || die 3 "Failed to restore files"
ln -sf "${BACKUP_FILE_REPO}/attachments" "/${DATA_FOLDER}/"
rm -rf "/${DATA_FOLDER}/icon_cache" && ln -sf "/${BACKUP_FILE_REPO}/icon_cache" "/${DATA_FOLDER}/"
echo "Restore Files OK"
/inotify_backup_file.sh &

# Periodically backup every minutes
while true
do
  sleep 60
  if [ "${POLLING_BACKUP}" == "true" ]; then
    /git_backup.sh backup_db
    /git_backup.sh backup_file
  fi
done
