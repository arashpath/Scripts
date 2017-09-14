#!/bin/bash
sed -e
echo "Installing Moodle"
#wget "https://download.moodle.org/stable33/moodle-3.3.1.tgz"
tar -xzf moodle-3.3.1.tgz -C /opt/APPS/
ln -s /opt/APPS/moodle /opt/apache/htdocs/moodle
mkdir -p /opt/docs/moodledata
chown daemon.daemon /opt/docs/moodledata /opt/APPS/moodle
psql -c "CREATE ROLE moodleuser LOGIN ENCRYPTED PASSWORD 'moodle@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE moodledb WITH ENCODING='UTF8' OWNER moodleuser;"

sudo -u daemon /opt/DevEnv/PHP/bin/php /opt/APPS/moodle/admin/cli/install.php --lang=en \
--wwwroot=http://192.168.11.219/moodle \
--dataroot=/opt/docs/moodledata \
--dbtype='pgsql' \
--dbhost='localhost' \
--dbname='moodledb' \
--dbuser='moodleuser' \
--dbpass='moodle@123' \
--fullname='NewMoodleSite' \
--shortname='NewSite' \
--adminuser='fssai' \
--adminpass='F$$@i123' \
--adminemail='fssai.cdc@gmail.com' \
--agree-license \
--non-interactive
