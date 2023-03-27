#!/bin/bash

# Define variables
backup_dir="/user/hadoop/backup"
source_dir="/user/hadoop/source"
log_file="/home/hadoop/logs/backup.log"

# Delete the backup folder if it exists
hdfs dfs -test -d $backup_dir && hdfs dfs -rm -r $backup_dir

# Copy the source folder to the backup folder
hdfs dfs -cp -p $source_dir $backup_dir

# Validate that all files were copied successfully
validation=$(hdfs dfs -diff $source_dir $backup_dir)

if [[ $validation = "" ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Backup completed successfully." >> $log_file
else
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: Backup validation failed. Files were not copied successfully." >> $log_file
    exit 1
fi
