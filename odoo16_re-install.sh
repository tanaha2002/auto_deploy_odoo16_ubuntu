#!/bin/bash
# Author: Nguyen Duong Thanh Du
# auto re-install odoo 16 on ubuntu 22.04
#chmod +x odoo16_re-install.sh
#--------SECTION 1 : BACKUP DATABASE------------------#
#database name
DB_NAME="your_database_name"
#database user
USER_NAME="your_username"
MASTER_PWD="pass123"
# path to store backup file
BACKUP_DIR="/home/ubuntu/backup_odoo_install"
BACKUP_ADDONS_DIR="/opt/odoo/odoo-server/custom_addons"
# # check if backup directory exists
# if [ ! -d "$BACKUP_DIR" ]; then
#     # create directory with permission 700
#     sudo mkdir -p $BACKUP_DIR
# fi
mkdir -p $BACKUP_DIR


# date-time backup file
CURRENT_DATE=$(date +"%Y%m%d%H%M%S")
FULL_NAME="$DB_NAME.$CURRENT_DATE.dump"
# create backup file
sudo pg_dump -U $USER_NAME -d $DB_NAME -Fc > $BACKUP_DIR/$FULL_NAME

# print message
echo "Done backup: $FULL_NAME"

#backup custom addons
sudo cp -r /opt/odoo/odoo-server/custom_addons $BACKUP_DIR/custom_addons



#--------SECTION 2 : UNISTALL ODOO------------------#
#stop service odoo
sudo systemctl stop odoo

#remove odoo
sudo rm -rf /opt/odoo
#stop service postgresql
sudo systemctl stop postgresql
#remove postgresql
# sudo apt-get purge postgresql -y
sudo apt-get purge postgresql*
#check postgresql
dpkg -l | grep postgresql

# sudo rm -rf /etc/postgresql/
# sudo rm -rf /var/lib/postgresql/
# sudo rm -rf /var/log/postgresql/

#install postgresql
sudo apt-get install postgresql -y
sudo su - postgres -c "createuser -s $USER_NAME" 
sudo apt-get install jq
#--------SECTION 3 : INSTALL ODOO------------------#
#create directory odoo
sudo mkdir /opt/odoo
cd /opt/odoo
#clone odoo 16
sudo git clone https://github.com/odoo/odoo.git --depth 1 --branch 16.0 --single-branch odoo-server 
# #install venv
cd /opt/odoo/odoo-server
python3 -m venv venv  
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
deactivate
# #copy back venv to new install
# sudo cp -r $BACKUP_DIR/venv /opt/odoo/odoo-server/venv

#copy back custom addons
sudo cp -r $BACKUP_DIR/custom_addons /opt/odoo/odoo-server/custom_addons

#give permission to ubuntu user
sudo chown -R ubuntu:ubuntu /opt/odoo/odoo-server

#--------SECTION 4 : CONFIGURE ODOO------------------#
sudo nano /etc/odoo-server.conf
#add this content
# [options]
# ; This is the password that allows database operations:
# admin_passwd = admin123
# db_user = ubuntu
# addons_path =/opt/odoo/odoo-server/addons,/opt/odoo/odoo-server/custom_addons
# logfile = /var/log/odoo/odoo-server.log
# log_level = debug

#--------SECTION 5 : RESTORE DATABASE------------------#
#restore database
#split name database back no have $current_date
#restore database to odoo16

sudo pg_restore -U $USER_NAME -d $DB_NAME -Fc $BACKUP_DIR/$FULL_NAME
# #rename database
sudo su - postgres -c "psql -c \"ALTER DATABASE $FULL_NAME RENAME TO $DB_NAME;\""
# curl -F 'master_pwd='$MASTER_PWD -F backup_file=$BACKUP_DIR/db1.2018-04-14.zip -F 'copy=true' -F 'name=db3' http://localhost:8069/web/database/restore



#--------SECTION 6 : START ODOO------------------#
sudo systemctl start odoo
sudo systemctl status odoo

# #get db list
# sudo su - postgres -c "psql -c \"SELECT datname FROM pg_database;\""
