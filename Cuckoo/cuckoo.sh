#################Requirements
sudo apt install git -y
sudo apt install python python-pip python-dev libffi-dev libssl-dev -y
sudo apt install python-virtualenv python-setuptools -y
sudo apt install libjpeg-dev zlib1g-dev swig -y
sudo pip install cryptography==2.2.1
sudo apt install net-tools
#################DB
sudo apt install mongodb -y
sudo apt install postgresql libpq-dev -y
#################VIRTUALBOX
sudo apt install virtualbox
sudo apt install virtualbox-ext-pack
#################tcpdump 
sudo apt install tcpdump apparmor-utils -y
sudo aa-disable /usr/sbin/tcpdump
#################Volatility
sudo git clone https://github.com/volatilityfoundation/volatility
cd volatility
sudo python ./setup.py install
cd ..
#################M2Crypto
sudo pip install m2crypto
#################Cuckoo
sudo pip install -U pip setuptools
sudo pip install -U cuckoo
sudo pip install distorm3
sudo mkdir /opt/cuckoo
host = hostname
user = whoami
sudo chown $user:$host /opt/cuckoo
cuckoo --cwd /opt/cuckoo 
wget https://az792536.vo.msecnd.net/vms/VMBuild_20180425/VirtualBox/MSEdge/MSEdge.Win10.VirtualBox.zip
sudo unzip MSEdge.Win10.VirtualBox.zip
path = pwd
mv MSEdge\ \-\ Win10.ova MSEdge-Win10.ova
sudo vboxmanage import MSEdge-Win10.ova
sudo vboxmanage hostonlyif create
sudo vboxmanage hostonlyif ipconfig vboxnet0 -ip 192.168.56.1





sudo iptables -A FORWARD -o ens32 -i vboxnet0 -s 192.168.56.0/24 -m conntrack –ctstate NEW -j ACCEPT
sudo iptables -A FORWARD -m conntrack –ctstate ESTABLISHED, RELATED -j ACCEPT
sudo iptables -A POSTROUTING -t nat -j MASQUERADE
sudo echo 1 > /proc/sys/net/ipv4/ip_forward
