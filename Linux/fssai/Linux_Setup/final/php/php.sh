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
  --with-mysqli \
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

# Custom Settings for Moodle
cp php.ini-production /opt/DevEnv/PHP/lib/php.ini
sed -i '
        s/^max_execution_time = 30$/max_execution_time = 120/
        s/^max_input_time = 60$/max_input_time = 300/
        s/^post_max_size = 8M$/post_max_size = 40M/
        s/^upload_max_filesize = 2M$/upload_max_filesize = 40M/
        s|^;date.timezone =$|date.timezone = "Asia/Kolkata"|
        /\[opcache\]/ a zend_extension=opcache.so
        s/^;opcache.enable=0$/opcache.enable=1/     
        s/^;opcache.enable_cli=0$/opcache.enable_cli=0/
        s/^;opcache.memory_consumption=64$/opcache.memory_consumption=128/
        s/^;opcache.interned_strings_buffer=4$/opcache.interned_strings_buffer=8/
        s/^;opcache.max_accelerated_files=2000$/opcache.max_accelerated_files=10000/
        s/^;opcache.revalidate_freq=2$/opcache.revalidate_freq=60/
        s/^;opcache.fast_shutdown=0$/opcache.fast_shutdown=1/
' /opt/DevEnv/PHP/lib/php.ini

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
/opt/DevEnv/PHP/bin/php -v