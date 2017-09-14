#!/bin/bash
set -e
datadir='/opt/psqlDATA'
#yum -y install "http://oscg-downloads.s3.amazonaws.com/packages/postgresql-9.5.6-1-x64-bigsql.rpm"
yum -y localinstall postgresql-9.5.6-1-x64-bigsql.rpm
/opt/postgresql/pgc init pg95 --datadir=$datadir
echo "source /opt/postgresql/pg95/pg95.env" >> ~/.bash_profile
ln -s /opt/postgresql/pg95/pg95.env /etc/profile.d/pg95.sh

systemctl enable postgresql95 
systemctl start postgresql95
source /opt/postgresql/pg95/pg95.env
#psql 
