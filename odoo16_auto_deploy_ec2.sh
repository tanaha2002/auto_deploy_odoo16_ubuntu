#!/bin/bash
# Author: Nguyen Duong Thanh Du
# auto re-install odoo 16 on ubuntu 22.04

#--------SECTION 1 : BACKUP DATABASE------------------#
#database name
DB_NAME="your_database_name"
#database user
USER_NAME="your_username"
# path to store backup file
BACKUP_DIR="/backups"

# check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    # create directory with permission 700
    mkdir -p $BACKUP_DIR
fi


# date-time backup file
CURRENT_DATE=$(date +"%Y%m%d%H%M%S")

# create backup file
pg_dump -U $USER_NAME -d $DB_NAME -Fc > $BACKUP_DIR/$DB_NAME-$CURRENT_DATE.dump

# print message
echo "Đã tạo tệp sao lưu: $DB_NAME-$CURRENT_DATE.dump"

#--------SECTION 2 : UNISTALL ODOO------------------#
#stop service odoo
sudo systemctl stop odoo

#remove odoo
sudo rm -rf /opt/odoo

#remove postgresql
sudo apt-get purge postgresql -y
sudo rm -r /etc/postgresql/
sudo rm -r /etc/postgresql-common/
sudo rm -r /var/lib/postgresql/
sudo userdel -rf postgres
sudo groupdel postgres

#install postgresql
sudo apt-get install postgresql -y
sudo su - postgres -c "createuser -s ubuntu" 