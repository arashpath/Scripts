#!/bin/bash
set -e
ID=$1
DEVENV=/opt/DevEnv ; HOME=$DEVENV/tomcat8-HOME
BASE=/opt/APPS/$(ls -lrth /opt/APPS/ | awk "/-tom"$ID"/ "'{print $9}')
# ---------------------------------------------------------------------------# 
if [ ! -d "$BASE" ] 
then 
  cp -a $HOME/webapps/manager $BASE/webapps/
  sed -i '/<Context/a <!--
        /<\/Context/i -->' $BASE/webapps/manager/META-INF/context.xml
  cp -a $HOME/conf/tomcat-users.* $BASE/conf/
  sed -i '/<\/tomcat-users>/i <user username="USER" password="PASSWD" roles="manager-gui,admin-gui"/>' $BASE/conf/tomcat-users.xml
  systemctl restart tomcat$ID
fi
