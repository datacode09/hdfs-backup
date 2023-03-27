#!/bin/bash

# Function to print error message and exit script
function error_exit {
    echo "$(date +'%Y-%m-%d %H:%M:%S') ERROR: $1" >&2
    exit 1
}

# Function to execute HDFS command with logging
function execute_hdfs_command {
    local command="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') INFO: Executing HDFS command: $command"
    eval "$command"
    if [ $? -ne 0 ]; then
        error_exit "HDFS command failed: $command"
    fi
}

# HDFS commands to execute
commands=(
    "hdfs dfs -mkdir /example"
    "hdfs dfs -put file.txt /example"
    "hdfs dfs -cat /example/file.txt"
)

# Execute HDFS commands with logging
for command in "${commands[@]}"; do
    execute_hdfs_command "$command"
done

echo "$(date +'%Y-%m-%d %H:%M:%S') INFO: HDFS commands completed successfully"
