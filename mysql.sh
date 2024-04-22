#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read  mysql_root_password

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo -e "$2  ...$R FAILURE $N"
    exit 1
    else
    echo -e "$2 ....$G SUCESS $N"
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi
 
 dnf install mysql-server -y &>>LOGFILE

 
 VALIDATE $? "MYSQL INSTALATTION"

 systemctl enable mysqld &>>LOGFILE
 VALIDATE $? "Enableing Mysql"

 systemctl start mysqld &>>LOGFILE
 VALIDATE $? "Starting Mysql"



#Below code will be useful for idempotent nature
mysql -h db.nettam.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi


