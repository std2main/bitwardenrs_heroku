#!/bin/bash

echo "Start to monitoring changes of ${DATABASE_URL}"
cd /data
# TODO: watching is not working now.
inotifywait -mrq --format '%w%f' -e modify "${DATABASE_URL}"  | while read line  
do
  echo "DB change detected: ${line}"
  ./scripts/backup.sh db
done
