#!/bin/bash

echo "Waiting to watch db change"
echo "Start to monitoring changes of ${DATABASE_URL}"
# TODO: watching is not working now.
inotifywait -mrq --format '%w%f' -e modify "${DATABASE_URL}"  | while read line  
do
  /git_backup.sh backup_db
done
