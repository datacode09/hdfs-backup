#!/bin/bash

# Set the source and backup directories
src_dir="/path/to/source/directory"
backup_dir="/path/to/backup/directory"

# Set the log file path
log_file="/path/to/log/file"

# Check if the backup directory already exists
if hdfs dfs -test -d "${backup_dir}"; then
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Removing existing backup directory..." >> "${log_file}"
  hdfs dfs -rm -r "${backup_dir}" >> "${log_file}" 2>&1
fi

# Create the backup directory
echo "$(date +"%Y-%m-%d %H:%M:%S"): Creating backup directory..." >> "${log_file}"
hdfs dfs -mkdir "${backup_dir}" >> "${log_file}" 2>&1

# Copy the files from the source directory to the backup directory
echo "$(date +"%Y-%m-%d %H:%M:%S"): Copying files from source to backup directory..." >> "${log_file}"
hdfs dfs -cp -p "${src_dir}/" "${backup_dir}/" >> "${log_file}" 2>&1

# Validate the contents of the source and backup directories
echo "$(date +"%Y-%m-%d %H:%M:%S"): Validating checksum of source directory..." >> "${log_file}"
src_checksum=$(hdfs dfs -checksum "${src_dir}" | awk '{print $1}')
backup_checksum=$(hdfs dfs -checksum "${backup_dir}" | awk '{print $1}')
if [[ "${src_checksum}" == "${backup_checksum}" ]]; then
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Checksums match, backup is valid." >> "${log_file}"
else
  echo "$(date +"%Y-%m-%d %H:%M:%S"): Checksums do not match, backup may be invalid." >> "${log_file}"
fi
