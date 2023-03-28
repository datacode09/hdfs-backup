#!/bin/bash

# Set the HDFS directories to backup
BACKUP_DIRS=("/hdfs/dir1" "/hdfs/dir2" "/hdfs/dir3")

# Set the backup directory name
BACKUP_NAME="hdfs_backup_$(date +%Y%m%d_%H%M%S)"

# Set the log file name
LOG_FILE="backup.log"

# Function to log messages to the log file
log_message() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") $1" >> $LOG_FILE
}

# Check if backup directory already exists
if hdfs dfs -test -d /$BACKUP_NAME; then
  log_message "Backup directory /$BACKUP_NAME already exists. Removing it..."
  hdfs dfs -rm -r /$BACKUP_NAME
fi

# Create backup directory
log_message "Creating backup directory /$BACKUP_NAME..."
hdfs dfs -mkdir /$BACKUP_NAME

# Backup each directory
for DIR in "${BACKUP_DIRS[@]}"; do
  DIR_NAME=$(basename $DIR)
  log_message "Backing up directory $DIR_NAME to /$BACKUP_NAME/$DIR_NAME..."
  hdfs dfs -cp -p $DIR /$BACKUP_NAME/
done

# Validate backup by comparing checksums of directories and backup directories
for DIR in "${BACKUP_DIRS[@]}"; do
  DIR_NAME=$(basename $DIR)
  log_message "Validating backup of $DIR_NAME..."
  DIR_CHECKSUM=$(hdfs dfs -checksum $DIR | cut -d " " -f 1)
  BACKUP_CHECKSUM=$(hdfs dfs -checksum /$BACKUP_NAME/$DIR_NAME | cut -d " " -f 1)
  if [ "$DIR_CHECKSUM" != "$BACKUP_CHECKSUM" ]; then
    log_message "Validation failed for $DIR_NAME. Checksums do not match."
  else
    log_message "Validation succeeded for $DIR_NAME."
  fi
done

