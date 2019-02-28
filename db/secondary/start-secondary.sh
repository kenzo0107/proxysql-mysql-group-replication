#!/bin/sh

while ! mysqladmin ping -h db-primary --silent; do
  sleep 1
done

mysql -u root -h db-primary -e "RESET MASTER;"
mysql -u root -h db-primary -e "FLUSH TABLES WITH READ LOCK;"

mysqldump -uroot -h db-primary --all-databases --master-data --single-transaction --flush-logs --events > /tmp/master_dump.sql

mysql -u root -e "STOP SLAVE;";
mysql -u root < /tmp/master_dump.sql

# masterに繋いで bin-logのファイル名とポジションを取得する
log_file=`mysql -u root -h db-primary -e "SHOW MASTER STATUS\G" | grep File: | awk '{print $2}'`
pos=`mysql -u root -h db-primary -e "SHOW MASTER STATUS\G" | grep Position: | awk '{print $2}'`

# slaveの開始
mysql -u root -e "RESET SLAVE";
mysql -u root -e "CHANGE MASTER TO MASTER_HOST='db-primary', MASTER_USER='root', MASTER_PASSWORD='', MASTER_LOG_FILE='${log_file}', MASTER_LOG_POS=${pos};"
mysql -u root -e "start slave"

# masterをunlockする
mysql -u root -h db-primary -e "UNLOCK TABLES;"
