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
db_list=$(python3 - <<END
import erppeek

server_url = 'http://localhost:8069'
client = erppeek.Client(server_url)

databases = client.db.list()
print("\n".join(databases))
END
)
for db_name_ in $db_list; do
    databases=$(curl -H "Content-Type: application/json" -d "{}" http://$db_name_.localhost:8069/web/database/list | jq -r '.result[]')

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
done

# backup only hold for latest 10 days
find $BACKUP_DIR -type f -mtime +10 -name "*.zip" -delete

#guide to use
#before run this script, make sure give it permission
#chmod +x back_daily_db.sh
#create a cron job to run this script daily
#crontab -e
#backup at 3:30 UTC time
#30 3 * * * /home/ubuntu/back_daily_db.sh
