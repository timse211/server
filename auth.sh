#!/bin/bash

read -p "Enter your directory name: " dirname
echo $dirname

# create protected dir.
if [ -d "/var/www/html/$dirname" ]; then
    echo "directory has existed"
else
    mkdir /var/www/html/$dirname
    echo "directory has build"
fi

testindexhtml="<html>\n <head><title>測試測試</title></head>\n <body>看到這個代表成功了</body>\n </html>"

echo -e $testindexhtml > /var/www/html/$dirname/index.html
echo "index.html has created"

# handle httd,conf settings
setting_var="AccessFileName .htaccess\n
<Files ~ \"^\.ht\">\n
    Order allow,deny \n
    Deny from all \n
    Satisfy All \n
</Files> \n

<Directory \"/var/www/html/$dirname\"> \n
    AllowOverride AuthConfig\n
    Order allow,deny\n
    Allow from all\n
</Directory>\n"

echo -e $setting_var >> /etc/httpd/conf/httpd.conf
systemctl restart httpd

# build users' .htaccess file settings
htac="AuthName    \"Protect test by .htaccess\"\n
Authtype     Basic\n
AuthUserFile /var/www/apache.passwd\n"

echo -e $htac > /var/www/html/$dirname/.htaccess


# create account and passwd for users

read -p "Enter your user name: " usrname
if  [ -f "/var/www/apache.passwd" ]; then
    echo "file exist, add new user"
    htpasswd /var/www/apache.passwd $usrname
else
    echo "file do not exit, add new user"
    htpasswd -c /var/www/apache.passwd $usrname
fi

while [ "$yn" != "yes" -a "$yn" != "YES" -a "$yn" != "no" -a "$yn" != "NO" ]
do
    read -p "Want to set this user belong to this dir?(yes/no):" yn
done

if [ "$yn"=="yes" -o "$yn"=="YES" ]; then
    echo -e "require user $usrname\n" >> /var/www/html/$dirname/.htaccess
else
    echo -e "require valid-user\n" >> /var/www/html/$dirname/.htaccess
fi

echo ".htaccess file is build"


cat /var/www/apache.passwd
echo "user confirmed"
