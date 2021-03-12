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

# Below flags depends on Project enviroments, won't allow modify by client
/git_backup.sh init || (echo "Failed to init git_backup"; exit 1)

# Restore things required when bitwarden_rs starting
if [ "${DATABASE_URL}" == "/db.sqlite3" ]; then
  echo "Using sqlite3"
else
  echo "DATABASE_URL is modified to ${DATABASE_URL}"
  exit 99
fi

export RSA_KEY_FILENAME="${BACKUP_DB_REPO}/rsa_key"
# Default to store things in DB_REPO, admin modified config will be their.
export DATA_FOLDER="${BACKUP_DB_REPO}/data"
/git_backup.sh restore_db || (echo "Failed to restore database"; exit 2)
echo "Restore DB OK"

# Store files and icons in FILE_REPO
export ATTACHMENTS_FOLDER="${BACKUP_FILE_REPO}/attachments/"
export ICON_CACHE_FOLDER="${BACKUP_FILE_REPO}/icons/"

# Disable log to not spam heroku log.
# May store to local and even in repo when needed.
/bin/sh /start.sh &

# Restore other things.
/git_backup.sh restore_file || (echo "Failed to restore files" ; exit 3)
echo "Restore Files OK"

sleep 60s
while true
do
  sleep 10s
  /git_backup.sh backup
done
