#!/bin/bash
PS3='Please enter your choice: '
options=("RHEL" "CENTOS" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "RHEL")
		yum -y upgrade
		echo "[*] Installing RHEL Nginx packages"
		rpm --import https://nginx.org/keys/nginx_signing.key 
		yum -y install http://nginx.org/packages/rhel/7/noarch/RPMS/nginx-release-rhel-7-0.el7.ngx.noarch.rpm
		yum -y install yum-plugin-priorities
		echo 'priority=1' >> /etc/yum.repos.d/nginx.repo
		yum -y install nginx
		yum -y install mod_ssl
		systemctl enable nginx
		systemctl start nginx
		break
		;;
	"CENTOS")
		yum -y upgrade
		echo "[*] Installing CentOS Nginx packages"
		rpm --import https://nginx.org/keys/nginx_signing.key 
		yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
		yum -y install yum-plugin-priorities
		echo 'priority=1' >> /etc/yum.repos.d/nginx.repo
		yum -y install nginx
		yum -y install mod_ssl
		systemctl enable nginx
		systemctl start nginx
		break
		;;
	"Quit")
            	break
            	;;
	*) echo "invalid option $REPLY";;
    esac
done
sleep 5
PS3='Do you want to install Mod_Security?: '
options=("yes" "no" "quit")
select opt in "${options[@]}"
do
    case $opt in
        "yes")
		echo "[*] Installing Mod_Security"
		yum install -y https://extras.getpagespeed.com/redhat/7/noarch/RPMS/getpagespeed-extras-7-0.el7.gps.noarch.rpm
		yum install -y nginx-module-security
		echo "[*] Downloading OWASP Core roules"
		yum install -y git
		cd /opt/
		git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
		cd owasp-modsecurity-crs/
		mkdir /etc/nginx/rules
		cp -R rules/ /etc/nginx/
		cp /opt/owasp-modsecurity-crs/crs-setup.conf.example /etc/nginx/crs-setup.conf
		#		
		echo "[*] Configuring OWASP Core roules"		
		# 
		echo "#Load OWASP Config" >> /etc/nginx/modsecurity.conf
		echo "Include crs-setup.conf" >> /etc/nginx/modsecurity.conf
		echo "#Load all other Rules" >> /etc/nginx/modsecurity.conf
		echo "Include rules/*.conf" >> /etc/nginx/modsecurity.conf
		echo "#Disable rule by ID from error message" >> /etc/nginx/modsecurity.conf
		echo "#SecRuleRemoveById 920350" >> /etc/nginx/modsecurity.conf
		sed -e "/nginx.pid;/a\\load_module modules/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf
		systemctl restart nginx
		echo "[*] Finished!!"
		echo "[*] Remember to set-up Mod-security roules in nginx conf (based on your host)"
		echo "Add following under “location /” directive"
		echo ">>     location / {"
		echo ">>     modsecurity on;"
		echo ">>     modsecurity_rules_file /etc/nginx/modsecurity.conf;"
		echo ">>     }"
		break
		;;
	"no")
		break
            	;;

	"Quit")
            	break
            	;;
	*) echo "invalid option $REPLY";;
    esac
done

#SED TAB
# sed -e "//var/run/nginx.pid;/a\\\tload_module modules/ngx_http_modsecurity_module.so;" /etc/nginx/nginx.conf
