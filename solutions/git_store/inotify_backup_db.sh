#!/bin/bash

cd /data
# TODO: watching is not working now.
inotifywait -mrq --format '%w%f' -e modify "/data/db.sqlite3"  | while read line  
do
  echo "DB change detected: ${line}"
  /git_backup.sh backup_db
done
