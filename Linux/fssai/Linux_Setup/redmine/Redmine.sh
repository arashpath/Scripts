## Redmine Installation
#Create DATABASE After Postgres Installation
psql -c "CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'redmine@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER redmine;"

##-------------
wget "http://www.redmine.org/releases/redmine-3.4.2.tar.gz"

tar -xzf redmine-*.tar.gz -C /opt/APPS/
ln -s /opt/APPS/redmine-*/ /opt/APPS/redmine
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
      domain: "fssai.gov.in"
      authentication: :login
      user_name: "fics@fssai.gov.in"
      password: "F$$@i2014"

  # Attachment Locations
  attachments_storage_path: /opt/docs/redmine/attachments
   
EOF

mkdir -p /opt/docs/redmine/attachments

yum install -y gcc-c++ rubygems ruby-devel ImageMagick-devel ImageMagick

echo <<EOF >/opt/APPS/redmine/Gemfile.local
# Gemfile.local
gem 'multi_json'
gem 'json'

EOF

gem install bundler
ruby -v
cd /opt/APPS/redmine/
bundle lock --add-platform x86_64-linux
bundle install --without development test

#gem 'nokogiri', '~> 1.6.8.rc2'

RAILS_ENV=production REDMINE_LANG=en bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=en bundle exec rake redmine:load_default_data
#Test
bundle exec rails server webrick -e production


##--------------------------------------------------
gem install passenger
yum -y install libcurl-devel
PATH=$PATH:/opt/apache/bin/
passenger-install-apache2-module


cat << EOF >> /opt/apache/conf/httpd.conf
# Redmine Connection (passenger)
Include conf/passenger.conf

EOF




cat << EOF > /opt/apache/conf/passenger.conf 
   LoadModule passenger_module /usr/local/share/gems/gems/passenger-5.1.8/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/share/gems/gems/passenger-5.1.8
     PassengerDefaultRuby /usr/bin/ruby
   </IfModule>

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
