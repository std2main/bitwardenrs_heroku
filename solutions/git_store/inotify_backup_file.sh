#!/bin/bash

readonly WATCH_DIR="/data/attachments"
echo "watching file change in  ${WATCH_DIR}"
#echo "Start to monitoring changes of ${ATTACHMENTS_FOLDER}"
# TODO: Consider making file level backup.
cd /data
while inotifywait -rq -e create,move,delete,modify "${WATCH_DIR}"
do
  echo "Attachment change monitored"
  ./scripts/backup.sh file
done
