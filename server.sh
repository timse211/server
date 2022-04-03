#!/bin/bash

yum install wget unzip httpd -y &&
echo "install wget and unzip instruction and apache server" &&
yum install php php-dom php-gd -y &&
echo "install php dependency package" &&
wget --no-check-certificate https://github.com/amd11141/server/raw/main/phpsysinfo-3.4.1.zip  &&
unzip phpsysinfo-3.4.1.zip &&
cp -rf phpsysinfo-3.4.1/* /var/www/html &&
mv /var/www/html/phpsysinfo.ini.new /var/www/html/phpsysinfo.ini &&
echo "phpsysinfo build" &&
wget --no-check-certificate https://github.com/amd11141/server/raw/main/nibbleblog-v4.0.5.zip  &&
cp nibbleblog-v4.0.5.zip /var/www/html/ &&
unzip /var/www/html/nibbleblog-v4.0.5.zip -d /var/www/html/ &> /dev/null &&
echo "unzip nibbleblog" &&
mv /var/www/html/nibbleblog-v4.0.5 /var/www/html/nibbleblog &&
chmod 777 /var/www/html/nibbleblog/content/ &&
setenforce 0 &&
echo "nibbleblog build" &&
systemctl stop firewalld &&
systemctl start httpd &&
echo "server is online"
