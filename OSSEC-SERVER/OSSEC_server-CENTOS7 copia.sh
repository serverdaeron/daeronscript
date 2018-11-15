#! /bin/bash
GREEN="\033[42m"
RED="\033[41m"
NC="\033[0m" # No Color
echo -e "${GREEN}[*]${NC} ${RED}Installing GCC, inotify and bind tools${NC}"
yum install -y gcc inotify-tools bind-utils wget
echo "[*] Set-up firewall (open 1514 tcp/udp) and get it permanent"
firewall-cmd --zone=public --add-port=1514/tcp --permanent
firewall-cmd --zone=public --add-port=1514/udp --permanent
systemctl restart firewalld
cd /usr/src
echo "[*] Download OSSEC SERVER 3.0.0"
wget -O Ossec.3.1.0.tar.gz https://github.com/ossec/ossec-hids/archive/3.1.0.tar.gz
tar xfvz Ossec.3.1.0.tar.gz
cd ossec-hids-3.1.0
sleep 1
"[*] Install OSSEC server, please follow the questions above:"
sleep 5
./install.sh
sleep 1
"[*] Start OSSEC server"
sleep 5
/var/ossec/bin/ossec-control start
firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="172.16.85.0/24"
  port protocol="tcp" port="1514" accept'
##/var/ossec/bin/ossec-control restart
##/var/ossec/bin/manage_agents
##/var/ossec/bin/list_agents -c
##/var/ossec/etc/ossec.conf
##/var/ossec/logs/ossec.log