#!/bin/bash
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV
# ---------------------------------------------------------------------------# 
tomcatURL="http://archive.apache.org/dist/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz"
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

cp -a $HOME/webapps/examples $BASE/webapps/

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
