$USER = whoami
#Enable universe and multiverse
sudo apt-add-repository multiverse && sudo apt-add-repository universe && sudo apt-get update
# Update
sudo apt upgrade -y && sudo apt dist-upgrade -y && sudo apt autoremove -y
#Enable universe and multiverse
sudo apt-add-repository multiverse && sudo apt-add-repository universe && sudo apt-get update
#optional service that provides the translation layer for RDP, VNC, and SSH
sudo apt install libguac-client-rdp0 libguac-client-vnc0 libguac-client-ssh0 guacd -y
# MongoDB
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
sudo echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt update
sudo apt install -y mongodb-org
sudo systemctl enable mongodb
sudo systemctl start mongodb
# Dependency
sudo apt install git python python-dev nginx libvirt-clients uwsgi uwsgi-plugin-python postgresql-client-common libvirt-daemon virt-manager python-virtualenv python3-virtualenv virtualenv libffi-dev virt-viewer qemu-kvm libvirt-bin virtinst bridge-utils cpu-checker python-pip python-m2crypto libmagic1 swig libvirt-dev upx-ucl libssl-dev wget unzip p7zip-full geoip-database libgeoip-dev libjpeg-dev mono-utils ssdeep libfuzzy-dev exiftool curl openjdk-11-jre-headless postgresql postgresql-contrib libpq-dev wkhtmltopdf tcpdump libcap2-bin clamav clamav-daemon clamav-freshclam python-pil suricata libboost-all-dev htop tmux gdebi-core tor privoxy libssl-dev libjansson-dev libmagic-dev automake apparmor-utils -y
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
# Required packages with PIP
sudo -H pip install psycopg2 distorm3 pycrypto cryptography==2.2.1 openpyxl
sudo -H pip install git+https://github.com/kbandla/pydeep.git
sudo -H pip install git+https://github.com/volatilityfoundation/volatility.git
sudo -H pip install pyopenssl -U
sudo -H pip install -U pip setuptools
# Add our user to the KVM and libvirt group
sudo usermod -a -G kvm $USER && sudo usermod -a -G libvirt $USER
# Enable packet capture in our VMs
sudo aa-disable /usr/sbin/tcpdump
sudo groupadd pcap
sudo usermod -a -G pcap $USER
sudo chgrp pcap /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
# Install Cuckoo Sandbox
sudo pip install cuckoo==2.0.6
# Adding YARA support
sudo wget https://github.com/VirusTotal/yara/archive/v3.8.1.zip && unzip v* && cd yara* && ./bootstrap.sh && ./configure --enable-cuckoo --enable-magic --enable-dotnet && make && sudo make install
# Add Cuckoo Community
cuckoo -d
cuckoo community
# Configure VM Guest in KVM
#user = whoami
#isoname = Win10_1809Oct_English_x64.iso
echo "Please, reade below instructions:"
echo "When virt-installation started, use these command to complete OS guest installation"
echo "Install in your OS tigerVNC (es, UBUNTU: sudo apt install tigervnc-viewer)"
echo "Show port used by Windows10 VM: sudo virsh dumpxml Windows10 | grep vnc"
echo "Create a port forwarding with ssh: ssh $IP -L 5900:127.0.0.1:5900"
echo "Start tigervn (es, UBUNTU: xtigervncviewer)"
echo "Or, use virt-viewer: sudo virt-viewer --connect=qemu+ssh://usr@ip/system --name Windows10"
sleep 10
#sudo virt-install --name Windows10 --ram=8192 --vcpus=4 --cpu host --hvm --disk path=/var/lib/libvirt/images/Windows.10-vm.qcow2,format=qcow2,size=50 --cdrom /home/$user/$isoname --graphics vnc
#sudo virsh start Windows10
#virsh snapshot-create Windows10
# Creating a database for Cuckoo Sandbox
#https://www.cyberciti.biz/faq/linux-kvm-stop-start-guest-virtual-machine/
sudo su postgres
psql
CREATE USER cuckoo WITH PASSWORD 'password';
CREATE DATABASE cuckoo;
GRANT ALL PRIVILEGES ON DATABASE cuckoo to cuckoo;
\q
exit
/data/kvm-images/Windows.10-vm.qcow2
/var/lib/libvirt/images/Windows.10-vm.qcow2
/data/kvm-images/Windows.7-vm.qcow2
/var/lib/libvirt/images/Windows.7-vm.qcow2
