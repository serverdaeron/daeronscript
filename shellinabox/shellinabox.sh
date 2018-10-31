#!/bin/bash
##########################
yum -y install epel-release
yum -y install shellinabox
systemctl enable shellinaboxd
systemctl start shellinaboxd
firewall-cmd --add-port=4200/tcp --permanent
systemctl restart firewalld
echo "Provide the IP for service access:"
read -p "IP: " IP
echo "!/bin/bash" >> /opt/telnet.sh
echo "telnet $IP" >> /opt/telnet.sh
chmod 777 /opt/telnet.sh
echo "OPTS=--service=/s:shellinabox:shellinabox:HOME:'/opt/telnet.sh"
adduser telnet
groupadd telnetusers
usermod -G telnetusers telnet
echo "telnetusers" >> /etc/security/telnet-group-users
echo "auth required pam_listfile.so item=group sense=allow file=/etc/security/telnet-group-users" >>  /etc/pam.d/remote