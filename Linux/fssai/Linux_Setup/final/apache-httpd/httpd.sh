#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

# URLs In-case Download Required
# Download link for httpd, APR, APR-UTI.
 httpdURL="https://archive.apache.org/dist/httpd/httpd-2.4.25.tar.gz"  
   aprURL="https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz"
  utilURL="https://archive.apache.org/dist/apr/apr-util-1.5.2.tar.gz"

# Installng Apache 2.4 ------------------------------------------------------#
yum -y install wget make gcc openssl-devel pcre-devel
echo -e "\nInstalling Apache\n"
##wget $httpdURL
tar -xzf $PKGS/httpd-2.4.*.tar.gz -C $DEVENV
mv $DEVENV/httpd-2.4*/ $DEVENV/httpd

#APR & APR UTI
##wget $aprURL
tar -xzf $PKGS/apr-1*.tar.gz -C $DEVENV
mv $DEVENV/apr-* $DEVENV/httpd/srclib/apr
##wget $utilURL
tar -xzf $PKGS/apr-util-*.tar.gz -C $DEVENV
mv $DEVENV/apr-util* $DEVENV/httpd/srclib/apr-util
cd $DEVENV/httpd

./configure -q 	--prefix=/opt/apache \
		--enable-mods-shared="all" \
		--with-included-apr	&& make -s && make -s install

rm -rf $DEVENV/httpd/

# Virtual hosts
sed -i '/httpd-vhosts\.conf/s/^.*$/Include\ conf\/vhost\.d\/\*\.conf/' /opt/apache/conf/httpd.conf
mkdir /opt/apache/conf/vhost.d
cat <<EOF > /opt/apache/conf/vhost.d/000-default.conf
<VirtualHost *:80>

</VirtualHost>


EOF

# Apache SystemCtl Script ----------------------#
cat <<EOF > /etc/systemd/system/apache.service
[Unit]
Description=The Apache HTTP Server

[Service]
Type=forking
EnvironmentFile=/opt/apache/bin/envvars
PIDFile=/opt/apache/logs/httpd.pid
ExecStart=/opt/apache/bin/apachectl start
ExecReload=/opt/apache/bin/apachectl graceful
ExecStop=/opt/apache/bin/apachectl stop
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

echo -e "\nApache Installation Completed\n"
/opt/apache/bin/apachectl -v
