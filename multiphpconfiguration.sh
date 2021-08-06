#!/bin/sh
os_name=`awk -F= '/^NAME/{print $2}' /etc/*-release | cut -d \" -f2 | awk '{ print $1 }'`
if [ $os_name = "CentOS" ]
then
#	echo "This is centos"
yum install httpd -y
yum install epel-release -y
yum install yum-utils -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum install php56 php56-php-fpm -y 
yum install php72 php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mysqlnd php72-php-xml php72-php-xmlrpc php72-php-opcache -y 
#yum install php72 php72-php-fpm php72-php-common php72-php-mysql php72-php-xml php72-php-xmlrpc php72-php-curl php72-php-gd php72-php-imagick php72-php-cli php72-php-dev php72-php-imap php72-php-mbstring php72-php-opcache php72-php-soap php72-php-zip php72-php-intl -y
systemctl stop php56-php-fpm
systemctl stop php72-php-fpm
sed -i 's/:9000/:9056/' /etc/opt/remi/php56/php-fpm.d/www.conf
sed -i 's/:9000/:9072/' /etc/opt/remi/php72/php-fpm.d/www.conf
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

echo -e "\n\t\t ## MultiPHP configuration Done. ##\t\t\n"
echo -e "### Add this configuration in  vhos file.\nFor php 5:\n 
AddHandler php56-fcgi .php
Action php56-fcgi /cgi-bin/php56.fcgi
Action php72-fcgi /cgi-bin/php72.fcgi 

\nAnd for php 72 add this :\n

AddHandler php72-fcgi .php
Action php56-fcgi /cgi-bin/php56.fcgi
Action php72-fcgi /cgi-bin/php72.fcgi
"
else
	echo "not centos"
fi
