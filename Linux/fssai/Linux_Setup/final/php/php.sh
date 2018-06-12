#!/bin/bash
# -*- coding: utf-8 -*-
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV
# ---------------------------------------------------------------------------# 
phpURL="http://in1.php.net/distributions/php-5.6.31.tar.gz"

# Installing PHP ------------------------------------------------------------#
echo -e "\nInstalling PHP\n"
#wget $phpURL
tar -xzf $PKGS/php-5.6.*.tar.gz -C $DEVENV
mv $DEVENV/php-5.6*/ $DEVENV/php
cd $DEVENV/php

yum -y install libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel \
	freetype-devel libicu-devel gcc-c++ openldap-devel libxslt-devel

./configure --prefix=$DEVENV/PHP \
  --with-apxs2=/opt/apache/bin/apxs \
  --enable-mbstring \
  --with-curl \
  --with-openssl \
  --with-xmlrpc \
  --enable-soap \
  --with-gd \
  --with-jpeg-dir \
  --with-png-dir \
  --with-mysql \
  --with-mysqli \
  --with-pdo-mysql --enable-pdo \
  --with-pgsql=/opt/postgresql/pg95/bin \
  --enable-embedded-mysqli \
  --with-freetype-dir \
  --with-ldap \
  --with-libdir=lib64 \
  --enable-intl \
  --enable-zip \
  --with-zlib \
  --enable-opcache \
  --with-xsl && make && make install

sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /opt/apache/conf/httpd.conf
cat << EOF >> /opt/apache/conf/httpd.conf
# PHP Configuration
<IfModule php5_module>
AddType application/x-httpd-php .php .php3 .phtml
AddType application/x-httpd-php-source .phps
</IfModule>
EOF


mkdir -p /opt/apache/htdocs/php
echo "<?php
  phpinfo();
?>" > /opt/apache/htdocs/php/index.php

systemctl restart apache 

echo "PHP Installed.."
$DEVENV/PHP/bin/php -v
