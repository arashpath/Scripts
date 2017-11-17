#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir $DEVENV

#Installing Apache HTTPD
echo "Installing Apache ..." && sleep 5 && sh $PKGS/apache-httpd/httpd.sh

#Installing Tomcat & JAVA
echo "Installing Tomcat ..." && sleep 5 && sh $PKGS/apache-tomcat/tomcat.sh

echo "Installing Tomcat ..." && sleep 5 && sh $PKGS/apache-tomcat/modjk.sh
