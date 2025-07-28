#!/bin/bash
USERID=$(id -u)

R="e\[31m"
G="e\[32m"
Y="e\[33m"
N="e\[0m"

LOG_FOLDER="/var/log/expense-log"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP.log"


VALIDATE ()
{
    if [ $1 -ne 0 ]
        then
        echo -e "$2 . . . $R Failure $N"
        exit 1
     else 
        echo -e "$1 ---- $G Success $N"
    fi
}


if [ USERID -ne 0]
 then 
 echo -e "$Y you must have sudo privileges $N"
 exit 1
fi

echo "script started executing at $TIMESTAMP &>>$LOG_FILE_NAME

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql server"

systemctl enable mysqld &>>$LOG_FILE_NAME
VALIDATE $? "enabling mysql service"

systemctl start mysqld &>>$LOG_FILE_NAME
VALIDATE $? "starting mysql service"

mysql -h mysql.srikanthannam.space -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE_NAME


if [ $? -ne 0]
  then 
      echo "MYSQL root password not set" &>>$LOG_FILE_NAME
      mysql_secure_installation --set-root-pass ExpenseApp@1
      VALIDATE $? "Setting Root Password"
else
      echo -e "MySQL Root password already setup ... $Y SKIPPING $N"
fi
