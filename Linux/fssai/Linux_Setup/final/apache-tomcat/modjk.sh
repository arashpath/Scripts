#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

# URLs In-case Download Required
# Download link for Java, Tomcat, httpd, APR, APR-UTI, MODJK  
    jkURL="http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"


# ModJK Connector -----------------------------------------------------------#
echo -e "\nInstalling ModJK Connector\n"
##wget $jkURL
tar -zxf $PKGS/tomcat-connectors-*-src.tar.gz -C $DEVENV
cd $DEVENV/tomcat-connectors-*-src/native
./configure -q --with-apxs=/opt/apache/bin/apxs && make -s && make -s install
rm -rf $DEVENV/tomcat-connectors-*-src/

cat <<EOF >> /opt/apache/conf/httpd.conf

# Tomcat connections (mod_jk)
Include conf/mod-jk.conf
EOF


cat <<EOF > /opt/apache/conf/mod-jk.conf
LoadModule jk_module  /opt/apache/modules/mod_jk.so
JkWorkersFile /opt/apache/conf/workers.properties
JkShmFile     /opt/apache/logs/mod_jk.shm
JkLogFile     /opt/apache/logs/mod_jk.log
JkLogLevel    info
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
EOF

touch /opt/apache/logs/mod_jk.shm /opt/apache/logs/mod_jk.log


cat <<EOF > /opt/apache/conf/workers.properties
worker.list=tom0

# Set properties for worker0 (ajp13)
worker.tom0.type=ajp13
worker.tom0.host=localhost
worker.tom0.port=8009


EOF

# Virtual hosts
cat <<EOF > /opt/apache/conf/vhost.d/tom0.conf
<VirtualHost *:80>
ServerName tom0.fssai.gov.in
ServerAlias tom0.fssai.gov.in
JkMount /* tom0
</VirtualHost>


EOF


echo -e "\nModJK Connecter Installed\n"
/opt/apache/bin/apachectl -t -D DUMP_MODULES
