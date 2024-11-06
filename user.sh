#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.cbpdevops.store

TIMESTAMP=$(date +F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script starting executing at $TIMESTAMP" &>> $LOGFILE


VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2 ...$R FAILED $N"
    else
         echo -e "$2 ...$G SUCCESS $N"
    fi     
}

if [ $ID -ne 0 ]
then
  echo -e  "$R ERROR : please run the script with root user $N"
  exit 1 # it is EXIT STATUS to check the above command is success or not (to check you can enter echo $? if it is 0 means success, other than 0 means failure), you can give other than 0
else
  echo "you are root user"
fi   

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabiling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enabiling  nodejs" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "installing nodejs" 

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi  

#useradd roboshop 

VALIDATE $? "creating roboshop user"

mkdir -p /app &>> $LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE

VALIDATE $? "downloading user application"

cd /app &>> $LOGFILE

unzip -o /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzipping user" 

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service

VALIDATE $? "copy user file"

systemctl daemon-reload

VALIDATE $? "deamon-reload"

systemctl enable user 

VALIDATE $? "enable user"

systemctl start user

VALIDATE $? "start user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

VALIDATE $? "coping mongorepo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "installing mongodb client" 

mongo --host $MONGODB_HOST</app/schema/user.js &>> $LOGFILE

VALIDATE $? "loading user data into mongodb" 
