#!/bin/bash

USERID=$(id -u)
 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"
 LOGS_FOLDER="/var/log/shell-roboshop"
 SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
START_TIME=$(date +%S)
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

dnf module disable redis -y  &>>$LOG_FILE
VALIDATE $? "Disabling Default Redis"
dnf module enable redis:7 -y  &>>$LOG_FILE
VALIDATE $? "Enabling Redis 7"
dnf install redis -y   &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Allowing Remote connections to Redis"

systemctl enable redis  &>>$LOG_FILE
VALIDATE $? "Enabling Redis"
systemctl start redis  &>>$LOG_FILE
VALIDATE $? "Starting Redis"