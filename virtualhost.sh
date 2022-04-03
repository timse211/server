#!/bin/bash

read -p "Input your directroy name: " dirname

echo $dirname

# create domain-oriented dir.
if [ -d "/var/www/$dirname" ]; then
    echo "directory has existed"
else
    mkdir /var/www/$dirname
    echo "directory has build"
fi

read -p "Input your domain name: " domainame
echo "$domainame" > /var/www/$dirname/index.html

virtualsetting="NameVirtualHost *:80\n
<Directory \"/var/www/$dirname\">\n
    Options FollowSymLinks\n
    AllowOverride None\n
    Order allow,deny\n
    Allow from all\n
</Directory>\n
<VirtualHost *:80>\n
    ServerName    $domainame\n
    DocumentRoot  /var/www/$dirname\n
</VirtualHost>\n"

maindomain="<VirtualHost *:80>\n
    ServerName    timse211.ddns.net\n
    DocumentRoot  /var/www/html\n
</VirtualHost>\n"

echo -e $virtualsetting >> /etc/httpd/conf.d/virtual.conf
echo -e $maindomain >> /etc/httpd/conf.d/virtual.conf

systemctl restart httpd
