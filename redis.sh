#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


TIMESTAMP=$(date +F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"
exec &>$LOGFILE

echo "script starting executing at $TIMESTAMP" &>> $LOGFILE


VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2 ...$R FAILED $N"
         exit 1
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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y


dnf module enable redis:remi-6.2 -y 

VALIDATE $? "enabiling redis"

dnf install redis -y 

VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf 

VALIDATE $? "allowing remote connections"

systemctl enable redis 

VALIDATE $? "enable redis"

systemctl start redis 

VALIDATE $? "start redis"