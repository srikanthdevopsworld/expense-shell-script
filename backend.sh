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
        echo -e "$2 . . . $R Failure $N "
        exit 1
     else 
        echo -e "$2 ---- $G Success $N "
    fi
}


if [ $USERID -ne 0 ]
 then 
 echo -e " $Y you must have sudo privileges $N "
 exit 1
fi

echo "script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installin nodejs 20"

id expense &>>$LOG_FILE_NAME

if [ $? -ne 0]
then 
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "adding expense user"
else
    echo -e "expense user exists $Y SKIPPING $N "
fi

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "crearting app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend"

cd /app

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell-script/backend.service /etc/systemd/system/backend.service


dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h mysql.srikanthannam.space -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "setting root password"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "deamon reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "enabling backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "start backend"