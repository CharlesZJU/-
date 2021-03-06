#!/bin/bash
# 整体拉取customer、product表数据
sqoop import --connect jdbc:mysql://cdh1:3306/source?useSSL=false --username root --password
mypassword --table customer --hive-import --hive-table rds.customer --hive-overwrite
sqoop import --connect jdbc:mysql://cdh1:3306/source?useSSL=false --username root --password
mypassword --table product --hive-import --hive-table rds.product --hive-overwrite
# 执行增量导入
sqoop job --exec myjob_incremental_import
# 调用 regular_etl.sql 文件执行定期装载
beeline -u jdbc:hive2://cdh2:10000/dw -f schedule_daily_etl.sql