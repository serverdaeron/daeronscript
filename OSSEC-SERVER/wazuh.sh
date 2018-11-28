#! /bin/bash
GREEN="\033[42m"
RED="\033[41m"
NC="\033[0m" # No Color
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "   What do you want to install?:    "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
PS3='Please enter your choice: '
options=("Wazuh-Manager" "ELK-forWazuh" "quit")
select opt in "${options[@]}"
do
    case $opt in
        "Wazuh-Manager")
echo -e "${GREEN}[*]${NC} ${RED}Installing GCC, inotify and bind tools${NC}"
yum install -y make gcc policycoreutils-python automake autoconf libtool wget
echo "[*] Set-up firewall (open 1514 tcp/udp) and get it permanent"
firewall-cmd --zone=public --add-port=1514/tcp --permanent
firewall-cmd --zone=public --add-port=1514/udp --permanent
systemctl restart firewalld
echo "[wazuh_repo]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=Wazuh repository
baseurl=https://packages.wazuh.com/3.x/yum/
protect=1" >> /etc/yum.repos.d/wazuh.repo
yum update -y
yum install wazuh-manager
            break
		    ;;
        "ELK-forWazuh")
echo -e "${GREEN}[*]${NC} ${RED}Installing the Wazuh API${NC}"
yum install -y yarn
echo "[elasticsearch-6.x]
name=Elasticsearch repository for 6.x packages
baseurl=https://artifacts.elastic.co/packages/6.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefre1
type=rpm- md" >> /etc/yum.repos.d/elastic.repo
echo "[wazuh_repo]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=Wazuh repository
baseurl=https://packages.wazuh.com/3.x/yum/
protect=1" >> /etc/yum.repos.d/wazuh.repo
curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
sudo yum install -y yarn
curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
yum install -y nodejs
yum install -y wazuh-api
systemctl status wazuh-api
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "    Elasticsearch-6.x     "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
curl -Lo jre-8-linux-x64.rpm --header "Cookie: oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jre-8u191-linux-x64.rpm"
rpm -qlp jre-8-linux-x64.rpm > /dev/null 2>&1 && echo "Java package downloaded successfully" || echo "Java package did not download successfully"
yum -y install jre-8-linux-x64.rpm
rm -f jre-8-linux-x64.rpm
yum install -y elasticsearch-6.4.3
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service
echo "Please, wait for ELastic Search config"
sleep 200
echo "${GREEN}[*]${NC} ${RED}Fore ES tuning: https://documentation.wazuh.com/current/installation-guide/optional-configurations/elastic-tuning.html#elastic-tuning${NC}"
sleep 30
curl https://raw.githubusercontent.com/wazuh/wazuh/3.7/extensions/elasticsearch/wazuh-elastic6-template-alerts.json | curl -XPUT 'http://localhost:9200/_template/wazuh' -H 'Content-Type: application/json' -d @-
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "     Logstash-6.4.3       "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
yum install logstash-6.4.3
curl -so /etc/logstash/conf.d/01-wazuh.conf https://raw.githubusercontent.com/wazuh/wazuh/3.7/extensions/logstash/01-wazuh-local.conf
usermod -a -G ossec logstash
systemctl daemon-reload
systemctl enable logstash.service
systemctl start logstash.service
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "         KIBANA           "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "         The Kibana plugin installation process may take several minutes. Please wait patiently.     "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yum install kibana-6.4.3
sudo -u kibana NODE_OPTIONS="--max-old-space-size=3072" /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.7.0_6.4.3.zip
echo "Optional. Kibana will only listen on the loopback interface (localhost) by default."
echo "To set up Kibana to listen on all interfaces, edit the file /etc/kibana/kibana.yml uncommenting"
echo "the setting server.host. Change the value to:"
echo "  server.host: "0.0.0.0"  "
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service
sed -i "s/^enabled=1/enabled=0/" /etc/yum.repos.d/elastic.repo
firewall-cmd --zone=public --permanent --add-port=5601/tcp
firewall-cmd --reload
echo "Open a web browser and go to the Kibana’s IP address on port 5601 (default Kibana port)."
sleep 30
break
;;
	    "Quit")
           	break
           	;;
	*) echo "invalid option $REPLY";;
    esac      
done

\b(client)\s+\K[[:alnum:]]+\.[[:alnum:]]+\.[[:alnum:]]+\.[[:alnum:]]+