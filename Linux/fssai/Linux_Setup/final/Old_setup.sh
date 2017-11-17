#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir $DEVENV

# URLs In-case Download Required
# Download link for Java, Tomcat, httpd, APR, APR-UTI, MODJK  
  javaURL="http://download.oracle.com/otn/java/jdk/8u111-b14/jdk-8u111-linux-x64.tar.gz"
tomcatURL="http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz"
 httpdURL="https://archive.apache.org/dist/httpd/httpd-2.4.25.tar.gz"  
   aprURL="https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz"
  utilURL="https://archive.apache.org/dist/apr/apr-util-1.5.2.tar.gz"
    jkURL="http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"

# Installing Java -----------------------------------------------------------#
echo -e "\nInstalling Java\n"
##wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $javaURL 
tar -xzf $PKGS/jdk-8*-linux-x64.tar.gz -C $DEVENV
mv $DEVENV/jdk1.8.*/ $DEVENV/jdk8
JAVA=$DEVENV/jdk8

echo -e "\nJava Installation Completed\n"
$JAVA/bin/java -version

# Installing Tomcat ---------------------------------------------------------#
echo -e "\nInstalling Tomcat\n"
##wget $tomcatURL
tar -xzf $PKGS/apache-tomcat-8*.tar.gz -C $DEVENV
mv $DEVENV/apache-tomcat-8*/ $DEVENV/tomcat8-HOME
HOME=$DEVENV/tomcat8-HOME

sed -i '/<Context/a \<!--
	/<\/Context>/i \-->' $HOME/webapps/manager/META-INF/context.xml  

sed -i '/<Context/a \<!--
	/<\/Context>/i \-->' $HOME/webapps/host-manager/META-INF/context.xml  

cat <<EOF > $HOME/conf/tomcat-users.xml                             
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>  
    <role rolename="manager-gui"/>
    <role rolename="manager-script"/>
    <role rolename="manager-jmx"/>
    <role rolename="manager-status"/>
    <role rolename="admin-gui"/>
    <role rolename="admin-script"/>
        <user username="Fadmin" password="3Cat" 
	    roles="manager-gui, manager-script, manager-jmx, manager-status, admin-gui, admin-script"/>
</tomcat-users>

EOF

BASE=/opt/APPS/default-tom0

mkdir -p $BASE/{bin,conf,logs,work,webapps,temp}
cp $HOME/conf/{server.xml,web.xml} $BASE/conf/

cat <<EOF > $BASE/bin/server.sh
export CATALINA_HOME=$HOME
export CATALINA_BASE=$BASE
export JAVA_HOME=$JAVA
\$CATALINA_HOME/bin/catalina.sh \$@
EOF

chmod +x $BASE/bin/server.sh

# Tomcat SystemCtl Script ----------------------#
cat <<EOF > /etc/systemd/system/tomcat0.service
# Systemd unit file for tomcat0 8080 port
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=CATALINA_HOME=$HOME
Environment=CATALINA_BASE=$BASE
Environment=CATALINA_PID=$BASE/temp/tomcat.pid

ExecStart=/bin/sh -c '$BASE/bin/server.sh start'
ExecStop=/bin/sh -c '$BASE/bin/server.sh stop'

RestartSec=30
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo -e "\nTomcat Installation Completed\n"
$BASE/bin/server.sh version

# Installng Apache 2.4 ------------------------------------------------------#
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
yum -y install wget make gcc openssl-devel pcre-devel

./configure -q 	--prefix=/opt/apache 		\
		--enable-mods-shared="all" 	\
		--with-included-apr			&& make -s && make -s install

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
