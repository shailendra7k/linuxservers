#!/bin/sh
os_name=`awk -F= '/^NAME/{print $2}' /etc/*-release | cut -d \" -f2 | awk '{ print $1 }'`

ftp_server(){
$2 install vsftpd -y
kill -9 21
systemctl restart vsftpd
systemctl enable vsftpd

echo "Configuring ftp ..."
mv $3 $3-back
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
pam_service_name=$4
userlist_enable=YES
tcp_wrappers=YES
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
chroot_local_user=YES
allow_writeable_chroot=YES
" >> $3
touch /etc/vsftpd.userlist
setsebool -P ftp_home_dir on
semanage boolean -m ftpd_full_access --on
systemctl restart vsftpd
echo -e "###################################################################\n"
echo -e "###################################################################\n"
echo -e "\n\t confirm your installtion done properly.\n\t whenever you create a FTP user add username in ### /etc.userlist ### file."
echo -e "\n\t Give shell to user according to you /bin/bash , /bin/ftp or /sbin/nologin !!\n"
echo -e "\n\n\t\tThankyou for using: \t Created by Shailendra kumar, contact: +919602743889, Email: shailendrakumarssk@gmail.com !!!\n"
echo -e "\n#################################################################"
echo -e "\n#################################################################"
}

#checking os type 

if [ $os_name = "Ubuntu" ]
        then
		dpkg -l vsftpd > /dev/null 2>&1
		if [ $? -ne 0 ];
			then
				packager=apt-get
				file_path=/etc/vsftpd.conf
				pam=ftp
		                ftp_server $os_name $packager $file_path $pam
		else 
			echo "vsftpd already installed"
		fi
elif [ $os_name = "CentOS" ]
        then
		rpm -q vsftpd > /dev/null 2>&1
		if [ $? -ne 0 ];
			then
				packager=yum
				file_path=/etc/vsftpd/vsftpd.conf
				pam=vsftpd
				ftp_server $os_name $packager $file_path $pam
		else
			echo "vsftpd already installed"
		fi
else
        echo "This is not Supporting OS"
fi
