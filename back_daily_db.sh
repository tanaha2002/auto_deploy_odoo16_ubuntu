#!/bin/bash
#vars
BACKUP_DIR=/home/ubuntu/backup
DB_NAME=BBSW_CRM
ADMIN_PASSWORD = pass123

# Create backup dir (-p to avoid warning if already exists)
mkdir -p $BACKUP_DIR

#Create a backup
curl -X POST \
    -F "master_pwd=${ADMIN_PASSWORD}" \
    -F "name=${DB_NAME}" \
    -F "backup_format=zip" \
    -o ${BACKUP_DIR}/${DB_NAME}_$(date +%F).zip \
    http://bbdesk.blueboltsoftware.com:8069/web/database/backup

# backup only hold for lates 10 days
find $BACKUP_DIR -type f -mtime +10 -name "${DB_NAME}.*.zip" -delete

#guide to use
#before run this script, make sure give it permission
#chmod +x back_daily_db.sh
#create a cron job to run this script daily
#crontab -e
#backup at 3:30 UTC time
#30 3 * * * /home/ubuntu/back_daily_db.sh
