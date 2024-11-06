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

dnf install nginx -y

VALIDATE $? "installing nginx"

systemctl enable nginx

VALIDATE $? "enable nginx"

systemctl start nginx

VALIDATE $? "start nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "downloaded web app"

cd /usr/share/nginx/html

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip

VALIDATE $? "unzipping web"

cp /home/centos/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf

VALIDATE $? "copied roboshop reverse proxy conf"

systemctl restart nginx 

VALIDATE $? "restart nginx"