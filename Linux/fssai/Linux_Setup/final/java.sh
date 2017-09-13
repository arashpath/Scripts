#!/bin/bash
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir $DEVENV
# ---------------------------------------------------------------------------# 
   jkURL="http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
# Installing Java -----------------------------------------------------------#
echo -e "\nInstalling Java\n"
##wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $javaURL 
tar -xzf $PKGS/jdk-8*-linux-x64.tar.gz -C $DEVENV
mv $DEVENV/jdk1.8.*/ $DEVENV/jdk8

JAVA=$DEVENV/jdk8
echo -e "\nJava Installation Completed\n"
$JAVA/bin/java -version