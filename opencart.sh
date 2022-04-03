#!/bin/bash
yum install php-mcrypt curl zlib php-gd php-mbsring php-xml php-mysql -y &&
yum install epel-release php-mcrypt -y &&
echo -e "All package are installed\n" &&

mkdir -p /var/www/html/opencart &&
cd /var/www/html/opencart/ &&
wget https://github.com/amd11141/server/raw/main/2.3.0.2-compiled.zip &&
unzip 2.3.0.2-compiled.zip &&
echo -e "operncart compile file installed\n" &&

chown -R apache:apache /var/www/html/opencart/upload &&
mv /var/www/html/opencart/upload/config-dist.php /var/www/html/opencart/upload/config.php &&
mv /var/www/html/opencart/upload/admin/config-dist.php /var/www/html/opencart/upload/admin/config.php &&
chmod 0755 /var/www/html/opencart/upload/system/storage/cache/ &&
chmod 0755 /var/www/html/opencart/upload/system/storage/logs/ &&
chmod 0755 /var/www/html/opencart/upload/system/storage/download/ &&
chmod 0755 /var/www/html/opencart/upload/system/storage/upload/ &&
chmod 0755 /var/www/html/opencart/upload/system/storage/modification/ &&
chmod 0755 /var/www/html/opencart/upload/image/ &&
chmod 0755 /var/www/html/opencart/upload/image/cache/ &&
chmod 0755 /var/www/html/opencart/upload/image/catalog/ &&
chmod 0755 /var/www/html/opencart/upload/config.php &&
chmod 0755 /var/www/html/opencart/upload/admin/config.php &&
echo -e "All file permission is completed\n" &&


systemctl restart httpd &&
systemctl restart httpd &&
echo -e "server is online\n"&&

systemctl stop firewalld &&
setenforce 0 &&
echo -e "WARNNING: firewall and SElinux is shutdown"
