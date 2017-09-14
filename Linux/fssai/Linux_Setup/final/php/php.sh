#!/bin/bash
set -e
#Install PHP
echo "Installing PHP"
#wget "http://in1.php.net/distributions/php-5.6.31.tar.gz"
tar -xzf php-5.6.31.tar.gz
cd php-5.6.31/

yum -y install libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libicu-devel gcc-c++ openldap-devel libxslt-devel
./configure --prefix=/opt/DevEnv/PHP \
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


cat << EOF >> /opt/apache/conf/httpd.conf
<IfModule php5_module>
AddType application/x-httpd-php .php .php3 .phtml
AddType application/x-httpd-php-source .phps
</IfModule>


EOF
