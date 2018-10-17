#! /bin/bash
##########################################################
echo "Insert your Virtual Host name [subdomain.doma.in]"
read -p "vhost: " site
echo "Insert internal IP"
read -p "IP: " ip
echo "Insert service port for interal IP"
read -p "Port: " port
######################################
PS3='Do you want a SSL certificate?'
options=("Yes" "No")
select opt in "${options[@]}"
do
    case $opt in
        "Yes")
PS3='What kind of certificate do you want? [your own or Let\'sencrypt?]: '
options=("MyOwn" "Let'sEncrypt" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "MyOwn")
            echo "Enter path for fullchain.pem"
            read fullchain
            echo "Enter path for fullchain.pem"
            read privkey    
            echo "ssl on;
            ssl_certificate $fullchain;
            ssl_certificate_key $privkey; 
            ssl_session_timeout 180m;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5; " >> /etc/nginx/conf-site/$site/ssl-$site.conf
                break
                ;;
        "Let'sEncrypt")
            yum -y install yum-utils
            yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
            yum -y install python2-certbot-nginx
            certbot --nginx certonly -d $site
            PS3='Do you want to set up certbot autorenew?'
            options=("Yes" "No")
            select opt in "${options[@]}"
                do
                case $opt in
                    "Yes")
                    echo "#!/bin/sh
                    if certbot renew > /var/log/letsencrypt/renew.log 2>&1 ; then
                        nginx -s reload
                            fi
                    exit" >> /etc/cron.daily/letsencrypt-renew
                        chmod +x /etc/cron.daily/letsencrypt-renew
                    echo "01 02,14 * * * /etc/cron.daily/letsencrypt-renew" >> /etc/crontab
                   break
            	   ;; 
                    "No")
            	   break
            	   ;;
	*) echo "invalid option $REPLY";;
    esac
done
            echo "ssl on;
            ssl_certificate /etc/letsencrypt/live/$site/fullchain.pem;
            ssl_certificate_key /etc/letsencrypt/live/$site/privkey.pem; 
            ssl_session_timeout 180m;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5; " >> /etc/nginx/conf-site/$site/ssl-$site.conf
                break
                ;;
        "Quit")
            	break
            	;;
	*) echo "invalid option $REPLY";;
    esac
done
                break
            	;;
        "No")
            	break
            	;;
	*) echo "invalid option $REPLY";;
    esac
done
echo "#HTTP 80 
server {
     listen 80;
     server_name $site;
     return 301 https://$site\$request_uri;
 }
# HTTPS 443 
server  {
     listen 443 ssl;
     keepalive_timeout 70;
     server_name $site;
     include /etc/nginx/conf-site/$site/ssl-$site.conf;
     include /etc/nginx/conf-site/$site/services-$site.conf;
     
     #auth_basic                            "Username and Password Required";
     #auth_basic_user_file                  /etc/nginx/.htpasswd;

     ModSecurityEnabled on;
     ModSecurityConfig modsec_includes.conf;
     
}" >> /etc/nginx/conf.d/$site.conf
#########################################
mkdir /etc/nginx/conf-site/$site
echo "proxy_redirect off;
proxy_http_version 1.1;
proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection \"upgrade\"; 
proxy_buffering off;
client_max_body_size 0;
proxy_connect_timeout  3600s;
proxy_read_timeout  3600s;
proxy_send_timeout  3600s;
send_timeout  3600s;" >> /etc/nginx/conf-site/$site/proxy-$site.conf
echo "location / {
proxy_set_header X-Forwarded-Proto https;
proxy_pass https://$ip:$port;
include /etc/nginx/conf-site/$site/proxy-$site.conf;
 }
" >> /etc/nginx/conf-site/$site/service-$site.conf
nginx -t
nginx -s reload
