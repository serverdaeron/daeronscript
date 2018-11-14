#!/bin/bash
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "  Script for compiling NGINX + MOD_SECURITY  "
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
yum -y upgrade
yum groupinstall -y "Development Tools"
yum install -y httpd httpd-devel pcre pcre-devel libxml2 libxml2-devel curl curl-devel openssl openssl-devel
cd /usr/src
git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git
cd ModSecurity
sed -i '/AC_PROG_CC/a\AM_PROG_CC_C_O' configure.ac
sed -i '1 i\AUTOMAKE_OPTIONS = subdir-objects' Makefile.am
./autogen.sh
./configure --enable-standalone-module --disable-mlogc
make
cd /usr/src
wget https://nginx.org/download/nginx-1.14.1.tar.gz
tar -zxvf nginx-* && rm -f nginx-*
groupadd -r nginx
useradd -r -g nginx -s /sbin/nologin -M nginx
cd nginx-*
./configure --user=nginx --group=nginx --add-module=/usr/src/ModSecurity/nginx/modsecurity --with-http_ssl_module
make
make install
sed -i "s/#user  nobody;/user nginx nginx;/" /usr/local/nginx/conf/nginx.conf
sed -e "/#pid logs/nginx.pid/a\\pid  /var/run/nginx.pid;"  /usr/local/nginx/conf/nginx.conf
echo "include modsecurity.conf
include owasp-modsecurity-crs/crs-setup.conf
include owasp-modsecurity-crs/rules/*.conf" >> /usr/local/nginx/conf/modsec_includes.conf
cp /usr/src/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsecurity.conf
cp /usr/src/ModSecurity/unicode.mapping /usr/local/nginx/conf/
sed -i "s/SecRuleEngine DetectionOnly/SecRuleEngine On/" /usr/local/nginx/conf/modsecurity.conf
sed -i "s/SecAuditLogType Serial/SecAuditLogType Concurrent/" /usr/local/nginx/conf/modsecurity.conf
sed -i "s|SecAuditLog /var/log/modsec_audit.log|SecAuditLog /usr/local/nginx/logs/modsec_audit.log|"        /usr/local/nginx/conf/modsecurity.conf
chown nginx.root /usr/local/nginx/logs
cd /usr/local/nginx/conf
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
cd owasp-modsecurity-crs
mv crs-setup.conf.example crs-setup.conf
cd rules
mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
echo "[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network.target remote-fs.target nss-lookup.target
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/local/nginx/sbin/nginx -t
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target" >> /lib/systemd/system/nginx.service
systemctl daemon-reload
systemctl start nginx.service