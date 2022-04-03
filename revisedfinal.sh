#!/bin/sh

echo -e "1)Multi Domain mapping settings\n2)virtual users access settings\n3)Indivisual Web Site settings\n4)vsftp settings\n5)nfs settings"

while :
    do
        case $num in
        1)
            echo -e "Multi Domain mapping settings\n";
            read -p "Input your directroy name:()" dirname
            echo $dirname

            # create domain-oriented dir.
            if [ -d "/var/www/$dirname" ]; then
                echo "directory has existed"
            else
                mkdir -p /var/www/$dirname/
                echo "directory has build"
            fi

            read -p "Input your domain name under /var/www/$dirname/: " domainame
            read -p "Input your domain name under /var/www/html/: " maindomainname
            echo "$domainame" > /var/www/$dirname/index.html
            echo -e "If you have some index.html just remove it!\n"

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
                ServerName    $maindomainname\n
                DocumentRoot  /var/www/html\n
            </VirtualHost>\n"

            echo -e $virtualsetting >> /etc/httpd/conf.d/virtual.conf
            echo -e $maindomain >> /etc/httpd/conf.d/virtual.conf

            systemctl restart httpd;;
        2)
			echo -e "virtual users access settings";
			while
			read -p "(1)/home/username or (2)/var/www/html" diroption
			if [ diroption == 1]
			read -p "Enter your home directory name:(/home/.../...)" dirname
			dir = /home/$dirname
			else if [ diroption == 2]
			read -p "Enter your directory name:(/var/www/html/..../...)" dirname
			dir = /var/www/html/$dirname
			else
			((1))
			do :; done


            # create protected dir.
            if [ -d "$dir" ]; then
                echo "directory has existed"
            else
                mkdir -p $dir
                echo "directory has build"
            fi

            testindexhtml="<html>\n <head><title>測試測試</title></head>\n <body>看到這個代表成功了</body>\n </html>"

            echo -e $testindexhtml > $dir/index.html
            echo -e "index.html has created\n"
            echo -e "please watch out you have created index.html in your $dir"

            # handle httd.conf settings
            setting_var="AccessFileName .htaccess\n
            <Files ~ \"^\.ht\">\n
                Order allow,deny\n
                Deny from all\n
                Satisfy All\n
            </Files>\n
            <Directory \"$dir\">\n
                AllowOverride AuthConfig\n
                Order allow,deny\n
                Allow from all\n
            </Directory>\n"

            echo -e $setting_var >> /etc/httpd/conf/httpd.conf
            systemctl restart httpd

            # build users .htaccess file settings
            htac="AuthName    \"Protect test by .htaccess\"\n
            Authtype     Basic\n
            AuthUserFile /var/www/apache.passwd\n"

            echo -e $htac > $dir/.htaccess


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
                read -p "Want to only set this user belong to this dir($dir/)?(yes/no):" yn
            done

            if [ "$yn"=="yes" -o "$yn"=="YES" ]; then
                echo -e "require user $usrname\n" >> $dir/.htaccess
            else
                echo -e "require valid-user\n" >> $dir/.htaccess
            fi

            echo ".htaccess file is build"


            cat /var/www/apache.passwd
            echo "user confirmed";;
        3)
            echo -e "Indivisual Web Site Settings\n"
            read -p "Do you want to add user? (yes/no): " yn
            if [ "$yn"=="yes" -o "$yn"=="YES" ]; then
                read -p "your user name: " nam
                adduser $nam
            fi
            read -p "difine your web site directory name:(/home/some user/...)": usrdirname
            echo  -e "Change your directory permission\n"
            chmod 755 /home/$nam/
            mkdir -p /home/$nam/www/
            chmod 711 /home/$nam/www/
            echo "It is $nam's web site" > /home/$nam/www/index.html
            websettings="<IFModule mod_userdir.c>\n
                UserDir enabled\n
                UserDir $usrdirname\n
            </IFModule>\n
            Alias /$nam/ \"/home/$nam/www/\"\n
            <Directory \"/home/*/www\">\n
                Options Indexes FollowSymLinks MultiViews\n
                AllowOverride FileInfo AuthConfig Limit Indexes\n
                Require method GET POST OPTIONS\n
            </Directory>\n"
            echo -e $websettings >> /etc/httpd/conf/httpd.conf
            echo -e "$nam's website is set!\n"
            echo -e "restart http and shut down SElinux\n"
            systemctl restart httpd
            setenforce 0;;
        4)
            echo -e "WARNNING: plase do it before install vsftp service!\n"
            echo -e "Please modify your user_list and chroot_list!\n"
            newsetting="userlist_enable=YES\nuserlist_deny=NO\nuserlist_file=/etc/vsftpd/user_list\n"
            newsettings="chroot_local_user=YES\nchroot_list_enable=YES\nchroot_list_file=/etc/vsftpd/chroot_list\nallow_writeable_chroot=YES\n"
            echo -e $newsetting >> /etc/vsftpd/vsftpd.conf
            echo -e $newsettings >> /etc/vsftpd/vsftpd.conf
            systemctl restart vsftpd
            echo -e "All settings and service is restart";;
        5)
            echo -e "WARNNING: plase do it before install rpcbid nfs nfslock service!\n"
            echo -e "Downloading port settings from github\n"
            wget https://github.com/amd11141/server/raw/main/portfire.xml
            cp portfire.xml /etc/firewalld/services/.
            echo -e "Adding nfs and rpc port\n"
            nfsrpcport="RQUOTAD_PORT=875\n
            LOCKD_TCPPORT=32803\n
            LOCKD_UDPPORT=32769\n
            MOUNTD_PORT=892\n"
            echo -e $nfsrpcport >> /etc/sysconfig/nfs
            echo -e "Add finished\n"
            echo -e "Start firewall\n"
            systemctl start firewalld
            echo -e "Add service and port"
            firewall-cmd --new-service-from-file=/etc/firewalld/services/portfire.xml --name=gogogo --permanent
            firewall-cmd --add-service=gogogo --permanent
            firewall-cmd --reload
            systemctl stop rpcbind && systemctl stop nfs && systemctl stop nfslock
            systemctl restart rpcbind && systemctl restart nfs && systemctl restart nfslock
            echo -e "All setting port is done\n";;
        6)
            echo -p "hidden option: remove firewall settings\n"
            firewall-cmd --remove-service=gogogo --permanent
            rm -rf /etc/firewalld/services/portfire.xml
            rm -rf /etc/firewalld/services/gogogo.xml
            firewall-cmd --reload;;
        e)
            echo "GoodBye!"
            break;;
        *)
            echo "repeat your instructions: ";;
        esac
    read -p "input your number:" num
    done