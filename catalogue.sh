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

validate $? "disabiling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

validate $? "enabiling  nodejs" 

dnf install nodejs -y &>> $LOGFILE

validate $? "installing nodejs" 

useradd roboshop &>> $LOGFILE

validate $? "creating roboshop user"

mkdir /app &>> $LOGFILE

validate $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

validate $? "downloading catalogue application"

cd /app &>> $LOGFILE

unzip /tmp/catalogue.zip &>> $LOGFILE

validate $? "unzipping catalogue application" 

npm install &>> $LOGFILE

validate $? "installing dependencies"

#use absolute path 
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

validate $? "coping catalogue file" 

systemctl daemon-reload &>> $LOGFILE

validate $? "daemon-reload catalogue" 

systemctl enable catalogue &>> $LOGFILE

validate $? "enabiling catalogue" 

systemctl start catalogue &>> $LOGFILE

validate $? "starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE

validate $? "coping mongorepo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

validate $? "installing mongodb client" 

mongo --host $MONGODB_HOST</app/schema/catalogue.js &>> $LOGFILE

validate $? "loading catalogue date into mongodb" 


