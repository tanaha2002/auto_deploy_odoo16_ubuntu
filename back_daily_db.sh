#!/bin/bash
#vars
#before run this script, make sure give it permission
#chmod +x back_daily_db.sh
#sudo apt-get install jq
BACKUP_DIR="/home/ubuntu/backup"
ADMIN_PASSWORD="admin123"
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)


# Create backup dir (-p to avoid warning if already exists)
mkdir -p "$BACKUP_DIR"

#get list database
databases=$(curl -H "Content-Type: application/json" -d "{}" http://localhost:8069/web/database/list | jq -r '.result[]')


for db_name in $databases; do
    BACKUP_NAME="${db_name}_${YEAR}_${MONTH}_${DAY}"
    # Create a backup
    curl -X POST \
        -F "master_pwd=$ADMIN_PASSWORD" \
        -F "name=$db_name" \
        -F "backup_format=zip" \
        -o "$BACKUP_DIR/$BACKUP_NAME.zip" \
        http://localhost:8069/web/database/backup
done


# backup only hold for lates 10 days
find $BACKUP_DIR -type f -mtime +10 -name "*.zip" -delete


#guide to use
#before run this script, make sure give it permission
#chmod +x back_daily_db.sh
#create a cron job to run this script daily
#crontab -e
#backup at 3:30 UTC time
#30 3 * * * /home/ubuntu/back_daily_db.sh
