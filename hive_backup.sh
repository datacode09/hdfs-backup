#!/bin/bash

# Set variables
DATABASE=<database_name>
TABLE=<table_name>
BACKUP_PATH=/path/to/backup/directory
LOG_FILE=/path/to/log/file.log

# Backup table to HDFS
echo "Backing up table $TABLE in database $DATABASE to $BACKUP_PATH" >> $LOG_FILE
hadoop fs -mkdir -p $BACKUP_PATH/$TABLE
hive -e "set hive.cli.print.header=false; set hive.exec.compress.output=true; set mapred.output.compression.codec=org.apache.hadoop.io.compress.SnappyCodec; INSERT INTO TABLE $DATABASE.$TABLE SELECT * FROM $DATABASE.$TABLE" 2>> $LOG_FILE
hadoop distcp $BACKUP_PATH/$TABLE hdfs://<namenode>/user/hive/warehouse/$DATABASE.db/$TABLE 2>> $LOG_FILE
hadoop fs -rm -r -skipTrash $BACKUP_PATH/$TABLE 2>> $LOG_FILE

# Validate backup table
echo "Validating backup table $TABLE in database $DATABASE" >> $LOG_FILE
hive -e "USE $DATABASE; DROP TABLE IF EXISTS backup_$TABLE; CREATE TABLE backup_$TABLE LIKE $TABLE; INSERT INTO TABLE backup_$TABLE SELECT * FROM $TABLE" 2>> $LOG_FILE

# Check for errors
if [ $? -eq 0 ]; then
  echo "Backup and validation of table $TABLE in database $DATABASE completed successfully" >> $LOG_FILE
else
  echo "Error backing up or validating table $TABLE in database $DATABASE" >> $LOG_FILE
  exit 1
fi
