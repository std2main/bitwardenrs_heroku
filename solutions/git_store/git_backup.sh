#!/bin/sh
# Reference: https://note.qidong.name/2017/12/use-git-to-backup-small-databases/

readonly TARGET_DB="${DATABASE_URL}"
readonly TMP_DB="/tmp/backup.db"

help(){
  echo "help"
}

commit_repo() {
  cd "$1"
  git add -A
  if git commit -m 'Auto backup'
  then
        set -xe
        git push
  fi
}

backup_sqlite3() {
  sqlite3 "${TARGET_DB}" ".backup ${TMP_DB}"
  sqlite3 "${TMP_DB}" .dump > ${BACKUP_DB_REPO}/backup.sql
}

clone_repo() {
  git clone "$1" "$2"
}

restore_sqlite3() {
  sqlite3 "${TARGET_DB}" < "${BACKUP_DB_REPO}/backup.sql"
}

init() {
  mkdir "$HOME/.ssh"
  echo "$BACKUP_GIT_SSH_KEY_B64" | base64 -d > "$HOME/.ssh/id_rsa"
  chmod 400 "$HOME/.ssh/id_rsa"
  chmod 700 "$HOME/.ssh"
  cat << EOF > "$HOME/.ssh/config"
Host *
  StrictHostKeyChecking no
EOF
  chmod 400 "$HOME/.ssh/config"

  git config --global user.email "heroku@backup"
  git config --global user.name "heroku backup"
}

command="$1"

case "${command}" in
    init)
      init
    ;;
    backup)
      backup_sqlite3
      commit_repo "${BACKUP_DB_REPO}"
      commit_repo "${BACKUP_FILE_REPO}"
    ;;
    restore_db)
      clone_repo "${BACKUP_DB_REPO_URL}" "${BACKUP_DB_REPO}"
      restore_sqlite3
    ;;
    restore_file)
      clone_repo "${BACKUP_FILE_REPO_URL}" "${BACKUP_FILE_REPO}"
    ;;
    --default)
      help
    ;;
esac

