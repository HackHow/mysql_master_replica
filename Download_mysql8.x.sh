#!/bin/bash

sudo yum update
sudo yum install gcc

## Download mysql rpm file
sudo yum install https://dev.mysql.com/get/mysql80-community-release-el7-6.noarch.rpm

# ls /etc/yum.repos.d
sudo yum repolist

## if check GPG-KEY fail, execute the command
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 
sudo yum install mysql-community-server

## start automatically at the next system restart
sudo systemctl enable mysqld

## start up mysql
sudo systemctl start mysqld

## print mysql temporary passwod
sudo grep 'temporary password' /var/log/mysqld.log

cat << EOF

***You need to input above display temporary password to below, and set new password***

EOF

cat << EOF
set mysql new password rules to root:
  At least one uppercase letter
  At least one lowercase letter
  At least one digit
  At least one special character

Total password length is at least 8 characters.

EOF

sudo mysql_secure_installation -p

# if you want to change mysql password and its strength, "please go to google" 