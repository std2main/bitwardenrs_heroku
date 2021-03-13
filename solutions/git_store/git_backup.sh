#!/bin/bash
# Reference: https://note.qidong.name/2017/12/use-git-to-backup-small-databases/


readonly TARGET_DB="${DATABASE_URL}"
readonly TMP_DB="/tmp/backup.db"

help(){
  echo "help"
}

commit_repo() {
  local REPO="${1}"
  cd "${REPO}"
  git add -A
  local CURRENT_TIME
  CURRENT_TIME="$(date +"%Y/%m/%d::%H:%M")"
  if [ -n "$(git status --porcelain)" ]; then
    if git commit --amend -m "Auto backup: ${BACKUP_SESSION} - ${CURRENT_TIME}"
    then
      git push -f
    fi
  else
    echo "no changes in ${REPO}";
  fi
}

backup_sqlite3() {
  exec {sqlite_lock_fd}> "/SQLITE_BACKUP_LOCK" || exit 1
  flock -n "${sqlite_lock_fd}" || { echo "ERROR: flock() failed." >&2; exit 1; }
  sqlite3 "${TARGET_DB}" ".backup ${TMP_DB}"
  sqlite3 "${TMP_DB}" .dump > ${BACKUP_DB_REPO}/backup.sql
  flock -u "${sqlite_lock_fd}"
}

clone_repo() {
  local URL="$1"
  local REPO="$2"
  git clone "${URL}" "${REPO}"
  # Create first commit when session start
  cd "${REPO}"
  echo "${BACKUP_SESSION}: Start" >> log.txt
  git add log.txt
  git commit -m "Auto backup: ${BACKUP_SESSION}"
}

restore_sqlite3() {
  sqlite3 "${TARGET_DB}" < "${BACKUP_DB_REPO}/backup.sql"
}

init() {
  mkdir -p "$HOME/.ssh"
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
    backup_db)
      backup_sqlite3
      commit_repo "${BACKUP_DB_REPO}"
    ;;
    backup_file)
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

