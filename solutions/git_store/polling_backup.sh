#!/bin/sh
cd /data
while true
do
  sleep 60
  /git_backup.sh backup_file
  /git_backup.sh backup_db
done
