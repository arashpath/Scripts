cd /opt/final
#wget "http://in1.php.net/distributions/php-5.6.31.tar.gz"
tar -xzf php-5.6.31.tar.gz 
cd php-5.6.31/

yum -y install libxml2-devel libcurl-devel libjpeg-turbo-devel libpng-devel freetype-devel libicu-devel gcc-c++ openldap-devel libxslt-devel
./configure \
  --prefix=/opt/DevEnv/PHP \
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

sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /opt/apache/conf/httpd.conf

mkdir /opt/apache/htdocs/php
echo "<?php
  phpinfo();
?>" > /opt/apache/htdocs/php/index.php

systemctl restart apache 

#############################################

cd /opt/final
#wget "https://download.moodle.org/stable33/moodle-3.3.1.tgz"
tar -xzf moodle-3.3.1.tgz -C /opt/APPS/
ln -s /opt/APPS/moodle /opt/apache/htdocs/moodle
mkdir -p /opt/docs/moodledata
chown daemon.daemon /opt/docs/moodledata /opt/APPS/moodle
psql -c "CREATE ROLE moodleuser LOGIN ENCRYPTED PASSWORD 'moodle@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE moodledb WITH ENCODING='UTF8' OWNER moodleuser;"
