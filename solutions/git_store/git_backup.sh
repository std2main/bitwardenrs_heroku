#!/bin/bash

readonly TARGET_DB="${DATABASE_URL}"

clone_repo() {
  local URL="$1"
  local REPO="$2"
  git clone "${URL}" "${REPO}"
  # Create first commit when session start
  cd "${REPO}"
  touch "logs/${BACKUP_SESSION}-start"
  git add -A
  git commit -m "${BACKUP_SESSION}"
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
    restore_db)
      clone_repo "${BACKUP_DB_REPO_URL}" "/data"
      cd "/data"
      ./scripts/restore_db.sh
    ;;
    restore_file)
      cd "/data"
      ./scripts/sync_files.sh
    ;;
    --default)
      exit 126
    ;;
esac

