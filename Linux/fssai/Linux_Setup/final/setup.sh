#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

ln -s /opt/DevEnv/dev.env /etc/profile.d/devEnv.sh

#Apache
echo "Installing Apache ..."     && sleep 5 && sh $PKGS/apache-httpd/httpd.sh

#Tomcat
#echo "Installing Tomcat ..."     && sleep 5 && sh $PKGS/apache-tomcat/tomcat.sh

#Modjk
#echo "Installing Modjk ..."      && sleep 5 && sh $PKGS/apache-tomcat/modjk.sh

#Installing PostgreSQL
#echo "Installing PostgreSQL ..." && sleep 5 && sh $PKGS/postgres/postgreSQL.sh

#Installing Ruby
#echo "Installing Ruby ..."       && sleep 5 && sh $PKGS/ruby/ruby.sh

#Installing Git
#echo "Installing Git ..."        && sleep 5 && sh $PKGS/git/git.sh

#Installing PHP
echo "Installing PHP ..."	     && sleep 5 && sh $PKGS/php/php.sh

#Installing MySQL
echo "Installing MySQL ..."     && sleep 5 && sh $PKGS/mysql.sh  
