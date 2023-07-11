#!/bin/bash
# Author: Nguyen Duong Thanh Du
# auto re-install odoo 16 on ubuntu 22.04
#chmod +x odoo16_auto_deploy.sh
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

#backup custom addons
sudo cp -r /opt/odoo/odoo-server/custom_addons /backups/addons-$CURRENT_DATE

#--------SECTION 2 : UNISTALL ODOO------------------#
#stop service odoo
sudo systemctl stop odoo

#remove odoo
sudo rm -rf /opt/odoo

#remove postgresql
sudo apt-get purge postgresql -y

# sudo rm -r /etc/postgresql/
# sudo rm -r /etc/postgresql-common/
# sudo rm -r /var/lib/postgresql/
# sudo userdel -rf postgres
# sudo groupdel postgres

#install postgresql
sudo apt-get install postgresql -y
sudo su - postgres -c "createuser -s osboxes" 

#--------SECTION 3 : INSTALL ODOO------------------#
#create directory odoo
sudo mkdir /opt/odoo
cd /opt/odoo
#clone odoo 16
sudo git clone https://github.com/odoo/odoo.git --depth 1 --branch 16.0 --single-branch odoo-server 
#install venv
cd /opt/odoo/odoo-server
python3 -m venv venv  
source venv/bin/activate
pip3 install wheel
pip3 install -r requirements.txt
deactivate

#--------SECTION 4 : CONFIGURE ODOO------------------#
sudo nano /etc/odoo-server.conf
#add this content
# [options]
# ; This is the password that allows database operations:
# admin_passwd = admin123
# db_user = osboxes
# addons_path =/opt/odoo/odoo-server/addons,/opt/odoo/odoo-server/custom_addons
# logfile = /var/log/odoo/odoo-server.log
# log_level = debug

#--------SECTION 5 : RESTORE DATABASE------------------#
#restore database



#--------SECTION 6 : START ODOO------------------#
sudo systemctl start odoo
sudo systemctl status odoo