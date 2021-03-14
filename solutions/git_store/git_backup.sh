#!/bin/bash
# Reference: https://note.qidong.name/2017/12/use-git-to-backup-small-databases/

readonly TARGET_DB="/data/db.sqlite3"
readonly _SQL_DUMP_FILE="/data/backup/backup.sql"
readonly _BAK_DB_REPO="/data"

warn () {
    echo "$0:" "$@" >&2
}
die () {
    rc=$1
    shift
    warn "$@"
    exit $rc
}

restore_sqlite3() {
  pushd "${_BAK_DB_REPO}"
  if [ -f "${_SQL_DUMP_FILE}" ]; then
    set -xe
    sqlite3 "${TARGET_DB}" < "${_SQL_DUMP_FILE}"
  else
    echo "Backup file ${_SQL_DUMP_FILE} not exists, do nothing."
  fi
  popd
}

commit_repo() {
  local REPO="${1}"
  pushd "${REPO}"
  git add -A
  local CURRENT_TIME
  CURRENT_TIME="$(date +"%Y/%m/%d_%H-%M")"
  if [ -n "$(git status --porcelain)" ]; then
    if git commit --amend -m "Auto: ${BAK_START_TIME} - ${CURRENT_TIME}"
    then
      git push -f
    fi
  else
    echo "no changes in ${REPO}";
  fi
  popd
}

backup_sqlite3() {
  exec {sqlite_lock_fd}> "/tmp/SQLITE_BACKUP_LOCK" || exit 1
  flock -n "${sqlite_lock_fd}" || { echo "ERROR: flock() failed." >&2; exit 1; }
  if [ -f "${TARGET_DB}" ]; then
    local TMP_DB="/tmp/backup.db"
    mkdir -p "${_BAK_DB_REPO}/backup"
    sqlite3 "${TARGET_DB}" ".backup ${TMP_DB}"
    sqlite3 "${TMP_DB}" .dump > "${_SQL_DUMP_FILE}"
    rm -f "${TMP_DB}"
  else
    echo "${TARGET_DB} does not exist"
  fi
  flock -u "${sqlite_lock_fd}"
}

clone_repo() {
  local URL="$1"
  local REPO="$2"

  git clone "${URL}" "${REPO}" || die 127 "Failed to clone ${URL}"

  # Create first commit when starting, all future commit will amend to this.
  cd "${REPO}"
  mkdir -p logs
  echo "." > "logs/${BAK_START_TIME}_start"
  git add -A
  git commit -m "Auto: ${BAK_START_TIME}"
}

backup_attachments(){
      unison -batch "${_BAK_FILE_REPO}/attachments" "/data/attachments"
}

backup_icon_cache() {
      unison -batch "${_BAK_FILE_REPO}/icon_cache" "/data/icon_cache"
}

restore_attachments(){
      unison -batch "${_BAK_FILE_REPO}/attachments" "/data/attachments"
}

restore_icon_cache() {
      unison -batch "${_BAK_FILE_REPO}/icon_cache" "/data/icon_cache"
}

# Initialize ssh and git enviroment.
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
      commit_repo "${_BAK_DB_REPO}"
    ;;
    backup_file)
      backup_attachments
      backup_icon_cache
      commit_repo "${_BAK_FILE_REPO}"
    ;;
    restore_db)
      clone_repo "${BACKUP_DB_REPO_URL}" "${_BAK_DB_REPO}"
      restore_sqlite3
    ;;
    restore_file)
      clone_repo "${BACKUP_FILE_REPO_URL}" "${_BAK_FILE_REPO}"
      restore_attachments
      restore_icon_cache
    ;;
    --default)
      exit 126
    ;;
esac

