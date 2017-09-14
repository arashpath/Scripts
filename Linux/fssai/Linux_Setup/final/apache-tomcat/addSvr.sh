#!/bin/bash
set -e
DEVENV=/opt/DevEnv
ID=$(( `ls -d /opt/APPS/*-tom? | rev | sort -n | awk END{print} | cut -c 1` + 1 )) 
APP=$1 ; [ -z "$APP" ] && APP="test$ID"
HOME=$DEVENV/tomcat8-HOME
JAVA=$DEVENV/jdk8

#DefaultPorts
Conn=$(( 8080 + ID ))
Sdow=$(( 8005 + ID + 100 )) #Adding 100 with port name
AJPp=$(( 8009 + ID ))
Redi=$(( 8443 + ID ))

BASE=/opt/APPS/$APP-tom$ID

mkdir -p $BASE/{bin,conf,logs,work,webapps,temp}
cp $HOME/conf/{server.xml,web.xml} $BASE/conf/

sed -i "
/shutdown/s/8005/$Sdow/
/<Connector\ port=\"8080\"\ protocol=\"HTTP\/1.1\"/s/8080/$Conn/
/<Connector\ port=\"8009\"\ protocol=\"AJP\/1.3\"\ redirectPort=\"8443\"\ \/>/s/8009/$AJPp/
/redirectPort=/s/8443/$Redi/
" $BASE/conf/server.xml

cat <<EOF > $BASE/bin/server.sh
export CATALINA_HOME=$HOME
export CATALINA_BASE=$BASE
export JAVA_HOME=$JAVA
echo "Using Tomcat Instance: $ID"
echo "Using Connection Port: $Conn"
echo "Using Shutdown Port:   $Sdow"
echo "Using AJP Port:        $AJPp"
echo "Using Redirect Port:   $Redi"
\$CATALINA_HOME/bin/catalina.sh \$@
EOF

chmod +x $BASE/bin/server.sh

# Tomcat SystemCtl Script ----------------------#
cat <<EOF > /etc/systemd/system/tomcat"$ID".service
# Systemd unit file for tomcat$ID
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


sed -i "/worker\.list/s/$/,tom$ID/" /opt/apache/conf/workers.properties

cat <<EOF >> /opt/apache/conf/workers.properties

# Set properties for worker$ID (ajp13)
worker.tom$ID.type=ajp13
worker.tom$ID.host=localhost
worker.tom$ID.port=$AJPp

EOF

# Virtual hosts
cat <<EOF > /opt/apache/conf/vhost.d/tom"$ID".conf
<VirtualHost *:80>
ServerName tom$ID.fssai.gov.in
ServerAlias tom$ID.fssai.gov.in
JkMount /* tom$ID
</VirtualHost>


EOF


echo -e "\nTomcat Installation Completed\n"
$BASE/bin/server.sh version

echo -e "\nVirtual Host Created\n"
/opt/apache/bin/apachectl -S
