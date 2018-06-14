#!/usr/bin/python
# -*- coding: utf-8 -*-

MyPass="MyPASS"

yum install -y mariadb-server
mv /var/lib/mysql /opt/mysqlDATA
sed -i 's/\/var\/lib\/mysql/\/opt\/mysqlDATA/p' /etc/my.cnf
systemctl start mariadb

echo "[client]
socket=/opt/mysqlDATA/mysql.sock" >  ~/.my.cnf

mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD('$MyPass') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "user=root
password=$MyPass" >>  ~/.my.cnf
