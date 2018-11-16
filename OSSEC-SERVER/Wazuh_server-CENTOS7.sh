#! /bin/bash
GREEN="\033[42m"
RED="\033[41m"
NC="\033[0m" # No Color
echo -e "${GREEN}[*]${NC} ${RED}Installing GCC, inotify and bind tools${NC}"
yum install -y gcc inotify-tools bind-utils wget make policycoreutils-python automake autoconf libtool
echo "[*] Set-up firewall (open 1514 tcp/udp) and get it permanent"
firewall-cmd --zone=public --add-port=1514/tcp --permanent
firewall-cmd --zone=public --add-port=1514/udp --permanent
systemctl restart firewalld
cd /usr/src
echo "[*] Download Wazuh SERVER"
wget -O Wazuh.tar.gz https://github.com/wazuh/wazuh/archive/v3.7.0.tar.gz
tar xfvz Wazuh.tar.gz
cd wazuh-*
sleep 1
"[*] Install Wazuh server, since Wazuh 3.5 it is necessary to have internet connection when following this step. Please follow the questions above:"
sleep 5
./install.sh
sleep 1
"[*] Start Wazuh server"
sleep 5
/var/ossec/bin/ossec-control start
/var/ossec/bin/ossec-control status
