#!/bin/bash

#database name
DB_NAME="your_database_name"
#database user
USER_NAME="your_username"
# path to store backup file
BACKUP_DIR="/opt/backups"

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

# # Khôi phục cơ sở dữ liệu từ tệp sao lưu
# read -p "Bạn có muốn khôi phục cơ sở dữ liệu từ tệp sao lưu này? (y/n) " choice
# if [[ $choice == "y" || $choice == "Y" ]]; then
#     read -p "Nhập tên cơ sở dữ liệu mới: " NEW_DB_NAME
#     psql -U your_username -c "CREATE DATABASE $NEW_DB_NAME"
#     pg_restore -U your_username -d $NEW_DB_NAME -Fc $BACKUP_DIR/$DB_NAME-$CURRENT_DATE.dump
#     echo "Đã khôi phục cơ sở dữ liệu thành công từ tệp sao lưu."
# else
#     echo "Không thực hiện khôi phục cơ sở dữ liệu."
# fi
