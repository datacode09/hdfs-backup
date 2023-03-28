#!/bin/bash

# define variables
SOURCE_DIRS="/hdfs/source/dir1 /hdfs/source/dir2 /hdfs/source/dir3"
BACKUP_DIR="/hdfs/backup"
LOG_FILE="/var/log/hdfs_backup.log"
DATE=$(date +%Y-%m-%d\ %H:%M:%S)
VALIDATION_ERROR=0

# loop over source directories and backup each one
for DIR in $SOURCE_DIRS; do
  # create backup directory if it doesn't exist
  if ! hdfs dfs -test -d $BACKUP_DIR/$(basename $DIR); then
    hdfs dfs -mkdir -p $BACKUP_DIR/$(basename $DIR)
  fi
  
  # backup the directory
  hdfs dfs -cp -p $DIR/* $BACKUP_DIR/$(basename $DIR)/
  
  # check for errors and log results
  if [ $? -eq 0 ]; then
    echo "$DATE: Successfully backed up $DIR to $BACKUP_DIR/$(basename $DIR)" >> $LOG_FILE
  else
    echo "$DATE: Failed to backup $DIR to $BACKUP_DIR/$(basename $DIR)" >> $LOG_FILE
    VALIDATION_ERROR=1
  fi
done

# validate checksum of backup directory contents
for DIR in $SOURCE_DIRS; do
  SOURCE_CHECKSUM=$(hdfs dfs -checksum $DIR/* | awk '{print $1}' | sort | md5sum | awk '{print $1}')
  BACKUP_CHECKSUM=$(hdfs dfs -checksum $BACKUP_DIR/$(basename $DIR)/* | awk '{print $1}' | sort | md5sum | awk '{print $1}')
  
  if [ "$SOURCE_CHECKSUM" != "$BACKUP_CHECKSUM" ]; then
    echo "$DATE: Validation error - checksum of $DIR does not match backup in $BACKUP_DIR/$(basename $DIR)" >> $LOG_FILE
    VALIDATION_ERROR=1
  else
    echo "$DATE: Successfully validated backup of $DIR in $BACKUP_DIR/$(basename $DIR)" >> $LOG_FILE
  fi
done

# exit with error code if there was a validation error
if [ $VALIDATION_ERROR -eq 1 ]; then
  exit 1
fi

exit 0
