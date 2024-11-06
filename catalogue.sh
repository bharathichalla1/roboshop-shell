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

dnf module disable nodejs -y

validate $? "disabiling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y

validate $? "enabiling  nodejs" &>> $LOGFILE

dnf install nodejs -y

validate $? "installing nodejs" &>> $LOGFILE

useradd roboshop

validate $? "creating roboshop user" &>> $LOGFILE

mkdir /app

validate $? "creating app directory" &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

validate $? "downloading catalogue application" &>> $LOGFILE

cd /app

unzip /tmp/catalogue.zip

validate $? "unzipping catalogue application" &>> $LOGFILE

npm install 

validate $? "installing dependencies" &>> $LOGFILE

#use absolute path 
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

validate $? "coping catalogue file" &>> $LOGFILE

systemctl daemon-reload

validate $? "daemon-reload catalogue" &>> $LOGFILE

systemctl enable catalogue

validate $? "enabiling catalogue" &>> $LOGFILE

systemctl start catalogue

validate $? "starting catalogue" &>> $LOGFILE

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo

validate $? "coping mongorepo" &>> $LOGFILE

dnf install mongodb-org-shell -y

validate $? "installing mongodb client" &>> $LOGFILE

mongo --host $MONGODB_HOST</app/schema/catalogue.js

validate $? "loading catalogue date into mongodb" &>> $LOGFILE



