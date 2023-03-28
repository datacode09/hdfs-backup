#!/bin/bash

# Set variables for directories to backup and backup location
backup_dirs=("/user/hadoop/dir1" "/user/hadoop/dir2" "/user/hadoop/dir3")
backup_location="/backup/hadoop/"

# Create log file
log_file="hdfs_backup_$(date +%Y-%m-%d_%H-%M-%S).log"
touch $log_file

# Loop through backup directories and execute HDFS backup commands
for dir in "${backup_dirs[@]}"
do
  # Create backup directory in backup location
  backup_dir="${backup_location}${dir##*/}"
  mkdir -p $backup_dir

  # Execute HDFS backup command for directory
  backup_command="hdfs dfs -cp -p ${dir} ${backup_dir}"
  echo "$(date +%Y-%m-%d\ %H:%M:%S) - Executing command: ${backup_command}" >> $log_file
  eval $backup_command

  # Check for errors and log result
  if [ $? -eq 0 ]
  then
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - Backup for ${dir} completed successfully" >> $log_file
  else
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - ERROR: Backup for ${dir} failed" >> $log_file
  fi
done

# Display completion message and log to file
echo "$(date +%Y-%m-%d\ %H:%M:%S) - Backup completed successfully" >> $log_file
