#!/bin/bash

## Redmine Installation
#Create DATABASE After Postgres Installation
source /opt/postgresql/pg95.env
psql -c "CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'redmine@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER redmine;"
echo "127.0.0.1   stgpsql" >> /etc/hosts

##-------------
redURL="https://www.redmine.org/releases/redmine-3.4.3.tar.gz"

curl --remote-name --progress $redURL
tar -xzf redmine-*.tar.gz -C /opt/APPS/
mv /opt/APPS/redmine{-*,}
cd /opt/APPS/redmine

cp /opt/APPS/redmine/config/database.yml{.example,}       
cp /opt/APPS/redmine/config/configuration.yml{.example,}  

cat << EOF > /opt/APPS/redmine/config/database.yml
# PostgreSQL configuration example
production:
  adapter: postgresql
  database: redmine
  host: stgpsql
  username: redmine
  password: "redmine@123"

EOF


cat << EOF > /opt/APPS/redmine/config/configuration.yml

production:
  # Outgoing emails configuration
  email_delivery:
    delivery_method: :smtp
    smtp_settings:
      address: mail.gov.in
      port: 465
      ssl: true
      enable_starttls_auto: true
      domain: "ORG.gov.in"
      authentication: :login
      user_name: "TEST@ORG.gov.in"
      password: "PASSWD"

  # Attachment Locations
  attachments_storage_path: /opt/docs/redmine/attachments
   
EOF


mkdir -p /opt/docs/redmine/attachments
chown -R daemon.daemon /opt/docs/redmine

yum install -y gcc-c++ ImageMagick-devel ImageMagick



gem install bundler
ruby -v
cd /opt/APPS/redmine/
bundle lock --add-platform x86_64-linux
bundle install --without development test



RAILS_ENV=production REDMINE_LANG=en bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data



##--------------------------------------------------
gem install passenger
yum -y install libcurl-devel
PATH=$PATH:/opt/apache/bin/
passenger-install-apache2-module

# Passenger Configuration
cat << EOF > /opt/apache/conf/passenger.conf 
   LoadModule passenger_module /opt/DevEnv/ruby/lib/ruby/gems/2.4.0/gems/passenger-5.1.12/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /opt/DevEnv/ruby/lib/ruby/gems/2.4.0/gems/passenger-5.1.12
     PassengerDefaultRuby /opt/DevEnv/ruby/bin/ruby
   </IfModule>

EOF


cat << EOF >> /opt/apache/conf/httpd.conf
# Redmine Connection (passenger)
Include conf/passenger.conf

EOF


# Creade a New vhost for redmine 
cat << EOF > /opt/apache/conf/vhost.d/redmin.conf
<VirtualHost *:80>
    ServerName yourserver.com

    # Tell Apache and Passenger where your app's 'public' directory is
    DocumentRoot /opt/APPS/redmine/public

    PassengerRuby /usr/bin/ruby

    # Relax Apache security settings
    <Directory /opt/APPS/redmine/public>
      Allow from all
      Options -MultiViews
      Require all granted
    </Directory>
	ErrorLog "logs/redmine-error_log"
	CustomLog "logs/redmine-access_log" common
</VirtualHost>

EOF

# Or Add To Existine Vhost
ln -s /opt/APPS/redmine/public /opt/apache/htdocs/redmine

cat << EOF >> /opt/apache/conf/vhost.d/000-default.conf
        <Directory /opt/apache/htdocs/redmine/>
            RailsBaseURI /redmine
            PassengerResolveSymlinksInDocumentRoot on
        </Directory>
		
EOF
