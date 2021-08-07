#!/bin/sh
read -p "Enter domain name: " domain_name
password=`openssl  rand -hex 7`
if [ -z "$domain_name" ]
then
        echo "Please Enter the domain Name to configure on Server"
        exit
else
        useradd $domain_name
        echo $password | passwd $domain_name --stdin
fi
apacheserver() {
sudo yum install httpd -y 
mkdir -p /var/www/$domain_name/public_html
echo "
<VirtualHost *:80>
    ServerAdmin webmaster@$domain_name
    ServerName $domain_name
    ServerAlias www.$domain_name
    DocumentRoot /var/www/$domain_name/public_html
    ErrorLog /var/log/httpd/$domain_name.error.log
    CustomLog /var/log/httpd/$domain_name.access.log combined

<Directory /var/www/$domain_name/public_html>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
</VirtualHost>
" >> /etc/httpd/conf.d/$domain_name.conf
sudo systemctl restart httpd 
echo  "<?php phpinfo(); ?>" >> /var/www/$domain_name/public_html/info.php
}

multiphp() {
yum install epel-release -y
yum install yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
yum install php56 php56-php-fpm php56-php-common php56-php-mysql php56-php-xml php56-php-xmlrpc php56-php-curl php56-php-gd php56-php-imagick php56-php-cli php56-php-dev php56-php-imap php56-php-mbstring php56-php-opcache php56-php-soap php56-php-zip php56-php-intl -y 
#yum install php72 php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache -y 
yum install php72 php72-php-fpm php72-php-common php72-php-mysql php72-php-xml php72-php-xmlrpc php72-php-curl php72-php-gd php72-php-imagick php72-php-cli php72-php-dev php72-php-imap php72-php-mbstring php72-php-opcache php72-php-soap php72-php-zip php72-php-intl -y

yum install php73 php73-php-fpm php73-php-common php73-php-mysql php73-php-xml php73-php-xmlrpc php73-php-curl php73-php-gd php73-php-imagick php73-php-cli php73-php-dev php73-php-imap php73-php-mbstring php73-php-opcache php73-php-soap php73-php-zip php73-php-intl -y

systemctl stop php56-php-fpm
systemctl stop php72-php-fpm
systemctl stop php73-php-fpm

#sed -i 's/:9000/:9056/' /etc/opt/remi/php56/php-fpm.d/www.conf
#sed -i 's/:9000/:9072/' /etc/opt/remi/php72/php-fpm.d/www.conf
#sed -i 's/:9000/:9075/' /etc/opt/remi/php72/php-fpm.d/www.conf

sed -i 's/127\.0\.0\.1\:9000/\/var\/run\/php56\-fpm\.sock/' /etc/opt/remi/php56/php-fpm.d/www.conf
sed -i 's/127\.0\.0\.1\:9000/\/var\/run\/php72\-fpm\.sock/' /etc/opt/remi/php72/php-fpm.d/www.conf
sed -i 's/127\.0\.0\.1\:9000/\/var\/run\/php73\-fpm\.sock/' /etc/opt/remi/php73/php-fpm.d/www.conf

systemctl start php72-php-fpm
systemctl start php56-php-fpm

cat > /var/www/cgi-bin/php56.fcgi << EOF
#!/bin/bash
exec /bin/php56-cgi
EOF
cat > /var/www/cgi-bin/php72.fcgi << EOF
#!/bin/bash
exec /bin/php72-cgi
EOF

sudo chmod 755 /var/www/cgi-bin/php56.fcgi
sudo chmod 755 /var/www/cgi-bin/php72.fcgi

sed -i "/<\/VirtualHost>/i AddHandler php72-fcgi .php \n Action php56-fcgi /cgi-bin/php56.fcgi \n Action php72-fcgi /cgi-bin/php72.fcgi" /etc/httpd/conf.d/$domain_name.conf
sudo systemctl reload httpd
}

database() {
echo "\n Installing Mariadb on Server...\n "

sudo yum install -y mariadb-server mariadb-client
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
}
#echo "Access website http://$domain_name/info.php or http://`ifconfig  | grep inet  | grep -v '127.0.0.1' | grep -v 'inet6' | awk '{print $2 }'`/info.php"

ftp_server(){

yum install vsftpd -y
kill -9 21
systemctl restart vsftpd
systemctl enable vsftpd

echo "Configuring ftp ..."
mv /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf-back
echo "anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
xferlog_std_format=YES
listen=NO
listen_ipv6=YES
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
chroot_local_user=YES
allow_writeable_chroot=YES
" >> /etc/vsftpd/vsftpd.conf
touch /etc/vsftpd.userlist
setsebool -P ftp_home_dir on
semanage boolean -m ftpd_full_access --on
systemctl restart vsftpd

#adding user to for ftp: 
echo $domain_name >> /etc/vsftpd.userlist

echo -e "###################################################################\n"
echo -e "###################################################################\n"
echo -e "\n\t confirm your installtion done properly.\n\t whenever you create a FTP user add username in ### /etc/vsftpd.userlist ### file."
echo -e "\n\t Give shell to user according to you /bin/bash , /bin/ftp or /sbin/nologin !!\n"
echo -e "\n\n\t\tThankyou for using: \t Created by Shailendra kumar, contact: +919602743889, Email: shailendrakumarssk@gmail.com !!!\n"
echo -e "\n#################################################################"
echo -e "\n#################################################################"
}

apacheserver
multiphp
database
ftp_server

echo -e "\n########################\n########################\nUser Name: $domain_name\nPassword: $password\n########################\n########################"

