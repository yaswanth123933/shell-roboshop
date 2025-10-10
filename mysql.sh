#!/bin/bash

USERID=$(id -u)
 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"
 LOGS_FOLDER="/var/log/shell-roboshop"
 SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(DAte +%s)
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo "ERROR:: Please run this script with root privelege"
    exit 1 #failure is other than zero
fi

VALIDATE(){ #functions receive inputs through argus just like script argus
   if [ $1 -ne 0 ];then
      echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE

      exit 1
   else
      echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE


   fi
}

dnf install mysql-server -y
VALIDATE $? "Installing MySQL Server"
systemctl enable mysqld
VALIDATE $? "Enabling MySQL Server"
systemctl start mysqld  
VALIDATE $? "Starting MySQL Server"
mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting up Root password"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $start_TIME))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"