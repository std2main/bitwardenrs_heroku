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

export BACKUP_DB_REPO="/backup_db"
export DATABASE_URL="/data/db.sqlite3"
/git_backup.sh init || (echo "Failed to init git_backup"; exit 1)
# Restore things required when bitwarden_rs starting
/git_backup.sh restore_db || (echo "Failed to restore database"; exit 2)
echo "Restore DB OK"
export RSA_KEY_FILENAME="${BACKUP_DB_REPO}/rsa_key"

# Default to store things in DB_REPO, admin modified config will be their.
export DATA_FOLDER="${BACKUP_DB_REPO}/data"
# Store files and icons in FILE_REPO
export BACKUP_FILE_REPO="/backup_files"
export ATTACHMENTS_FOLDER="${BACKUP_FILE_REPO}/attachments/"
export ORG_ATTACHMENT_LIMIT=10240
export USER_ATTACHMENT_LIMIT=10240
export ICON_CACHE_FOLDER="${BACKUP_FILE_REPO}/icons/"
export DISABLE_ICON_DOWNLOAD=false
export ICON_CACHE_TTL=2592000
export ICON_CACHE_NEGTTL=259200

# Disable log to not spam heroku log.
# May store to local and even in repo when needed.
export LOG_LEVEL=Off
/bin/sh /start.sh &

# Restore other things.
/git_backup.sh restore_file || (echo "Failed to restore files" ; exit 3)
echo "Restore Files OK"

while true
do
  sleep 10s
  /git_backup.sh backup
done
