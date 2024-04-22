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
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "diabling nodejs previous version"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "enabling Nodejs 20"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "installing Nodejs"


id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "Expense user already created...$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating app directry"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "dowanloading backend code"

cd /app
VALIDATE $? "change to application folder"
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

cp /home/ec2-user/exp-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

npm install &>>LOGFILE
VALIDATE $? " installing Nodejs dependenceiess"

systemctl daemon-reload &>>LOGFILE
VALIDATE $? "daemon user reload"

systemctl start backend &>>LOGFILE
VALIDATE $? "starting the backend"

systemctl enable backend &>>LOGFILE
VALIDATE $? "enabling the baclend"

dnf install mysql -y &>>LOGFILE
VALIDATE $? "installing sql client"

mysql -h db.nettam.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "setting dtabase root passward"

systemctl restart backend &>>LOGFILE
VALIDATE $? "resting backend"





