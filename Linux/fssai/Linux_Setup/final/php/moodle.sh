#!/bin/bash
set -e
echo "Installing Moodle"
#wget "https://download.moodle.org/stable33/moodle-3.3.1.tgz"
mkdir -p /opt/APPS/
tar -xzf moodle-3.3.1.tgz -C /opt/APPS/
mkdir -p /opt/docs/moodledata
chown daemon.daemon /opt/docs/moodledata /opt/APPS/moodle

source /opt/postgresql/pg95.env 
psql -c "CREATE ROLE mdluser LOGIN ENCRYPTED PASSWORD 'moodle@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE moodle WITH ENCODING='UTF8' OWNER mdluser;"

sudo -u daemon /opt/DevEnv/PHP/bin/php /opt/APPS/moodle/admin/cli/install.php --lang=en \
--wwwroot=http://snfportal.in/cert \
--dataroot=/opt/docs/moodledata \
--dbtype='pgsql' \
--dbhost='psqlsnfdb' \
--dbname='moodle' \
--dbuser='mdluser' \
--dbpass='moodle@123' \
--fullname='NewMoodleSite' \
--shortname='NewSite' \
--adminuser='admin' \
--adminpass='admin@123' \
--adminemail='admin@mail.com' \
--agree-license \
--non-interactive

ln -s /opt/APPS/moodle /opt/apache/htdocs/moodle
