#! /bin/bash
# Thank's to 5kuby
# Originally posted on https://github.com/5kuby/Graylog/blob/master
GREEN='\033[0;32m'
NC='\033[0m' # No Color
pass_admin='graylog'
echo -e "[*] ${GREEN}Type the IP address of this server ${NC}[and press ENTER]:"
read -p "IP Address: " ip_addr
#Update Centos and Setup FirewallD
echo -e "[*] ${GREEN}Update RHEL and set up Firewall${NC}"
sudo yum update -y
sudo systemctl start firewalld
sudo firewall-cmd --zone=public --add-port=9000/tcp --permanent
sudo firewall-cmd --zone=public --add-port=22/tcp --permanent
sudo systemctl restart firewalld
sleep 1
echo -e "[*] ${GREEN}RPM FUSION installation${NC}"
sudo yum localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm
sleep 1
echo -e "[*] ${GREEN}Utility installation ${NC}[Perl-Digest, net-tools, PWgen, Java-OpenJDK and epel Repository]"
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum install -y perl-Digest-SHA net-tools.x86_64 pwgen.x86_64 java-1.8.0-openjdk wget nano
echo -e "[*] ${GREEN}Add MongoDB reporsitory${NC} and install it"
sudo echo "[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc" >> /etc/yum.repos.d/mongodb-org.repo
sleep 1
sudo yum update -y
sleep 1
sudo yum -y install mongodb-org && sudo systemctl enable mongod && sudo systemctl start mongod
echo -e "[*] ${GREEN}Add Elasticsearch repository ${NC}and install it"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo echo "[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" >> /etc/yum.repos.d/elasticsearch.repo
sleep 1
sudo yum update -y
sleep 1
sudo yum -y install elasticsearch
# set graylog as name of elastic cluster
sudo sed -i 's/#cluster.name: my-application/cluster.name: GrayLOG/g' /etc/elasticsearch/elasticsearch.yml
sudo chkconfig --add elasticsearch
sudo systemctl daemon-reload
sudo systemctl enable elasticsearch.service
sudo systemctl restart elasticsearch.service
echo -e "[*] ${GREEN}Install GrayLog repository and server${NC}"
sleep 1
sudo rpm -Uvh https://packages.graylog2.org/repo/packages/graylog-2.4-repository_latest.rpm
sudo yum -y install graylog-server
##################################
###Add password control###########
##################################
while  [[ $pass_admin != $pass_admin2 ]]
	do
		echo -e "[*] ${GREEN}Insert password for Admin user  ${NC}[It will be stored encrypted]:"
		read -p "Insert PWD: " pass_admin
		echo -e "[*] ${GREEN}Reinsert the password:${NC}"
		read -p "Confirm PWD: " pass_admin2
	done
# encrypt password remove  - at the end of sha256sum output. the has is stored in the $pass var
pass=$( echo -n $pass_admin | sha256sum | sed 's/-//g')
# inserisco la variabile pass e imposto la password di admin con il valore immesso $pass_admin. Le " in sed elaborano le variabili
sudo sed -i "s/root_password_sha2 =/root_password_sha2 = $pass/g" /etc/graylog/server/server.conf
# do some graylog configuration:
# Set timezone, see http://www.joda.org/joda-time/timezones.html for a list of valid time zones.
sudo sed -i 's|#root_timezone = UTC|root_timezone = Europe/\Rome|g' /etc/graylog/server/server.conf
# configure rest listen uri
sudo sed -i "s|rest_listen_uri = http:\/\/127.0.0.1:9000\/api\/|rest_listen_uri = http:\/\/$ip_addr:9000\/api\/|g" /etc/graylog/server/server.conf
# Enable web interface and set listen ip
sudo sed -i 's|#web_enable = false|web_enable = true|g' /etc/graylog/server/server.conf
sudo sed -i "s|#web_listen_uri = http:\/\/127.0.0.1:9000\/|web_listen_uri = http:\/\/$ip_addr:9000\/|g" /etc/graylog/server/server.conf
# set password secret
pass_secret=$(pwgen -N 1 -s 96)
sudo sed -i "s/password_secret =/password_secret = $pass_secret/g" /etc/graylog/server/server.conf
# set some Java options (heap size and ipv4 as preferred stack)
sudo sed -i 's|GRAYLOG_SERVER_JAVA_OPTS="-Xms1g -Xmx1g -XX:NewRatio=1 -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow"|GRAYLOG_SERVER_JAVA_OPTS="-Djava.net.preferIPv4Stack=true -Xms4g -Xmx4g -XX:NewRatio=1 -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow"|g' /etc/sysconfig/graylog-server
clear
sudo systemctl enable graylog-server
sudo systemctl restart graylog-server
clear
echo -e "[*] ${GREEN}Finished!!${NC}"
