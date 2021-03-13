#!/bin/bash

echo "Waiting to watch file change"
echo "Start to monitoring changes of ${ATTACHMENTS_FOLDER}"
# TODO: Consider making file level backup.
while inotifywait -rqq -e create,move,delete,modify "${ATTACHMENTS_FOLDER}"
do
  /git_backup.sh backup_file
done
