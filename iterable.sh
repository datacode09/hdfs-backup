#!/bin/bash

# Define the log file path
LOG_FILE="/path/to/hdfs-commands.log"

# Define the HDFS commands to execute
HDFS_COMMANDS=(
  "hdfs dfs -ls /path/to/directory"
  "hdfs dfs -mkdir /path/to/new/directory"
  "hdfs dfs -put /path/to/local/file /path/to/hdfs/directory"
)

# Iterate over the HDFS commands
for CMD in "${HDFS_COMMANDS[@]}"
do
  # Execute the command and redirect the output to the log file
  { 
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Running command: $CMD"
    eval "$CMD"
  } >> "$LOG_FILE" 2>&1

  # Check the command's exit status
  if [ $? -ne 0 ]; then
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERROR: Command failed: $CMD"
    exit 1
  fi
done
