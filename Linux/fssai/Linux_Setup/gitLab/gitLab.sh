#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV



# Git URL 
 gitURL="https://www.kernel.org/pub/software/scm/git/git-2.15.0.tar.gz"
 gitSUM="25762cc50103a6a0665c46ea33ceb0578eee01c19b6a08fd393e8608ccbdb3da" 

# Ruby URL
rubyURL="https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.gz"
rubySUM="93b9e75e00b262bc4def6b26b7ae8717efc252c47154abb7392e54357e6c8c9c"

# GO URL
  goURL="https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz"
  goSUM="de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b"

# NodeJs URL
nodeURL="https://nodejs.org/dist/v8.9.1/node-v8.9.1-linux-x64.tar.gz"
nodeSUM="0e49da19cdf4c89b52656e858346775af21f1953c308efbc803b665d6069c15c"

# Installing GIT ------------------------------------------------------------#
yum -y install make automake gcc gcc-c++ kernel-devel zlib-devel \
 libyaml-devel openssl-devel gdbm-devel pcre2-devel readline-devel \
 ncurses-devel libffi-devel curl openssh-server libxml2-devel libxslt-devel \
 libcurl-devel libicu-devel logrotate python-docutils pkgconfig cmake

yum install perl-CPAN
cpan -i ExtUtils::MakeMaker

cd $PKGS; curl --remote-name --progress $gitURL
echo "$gitSUM $(ls  git-*.tar.gz)" \
 | sha256sum -c - && tar xzf git-*.tar.gz 
cd git-* && ./configure --prefix=$DEVENV/git/ && make all && make install

echo "Git Installed ..."
$DEVENV/git/bin/git --version

# Installing Ruby ------------------------------------------------------------#
cd $PKGS; curl --remote-name --progress $rubyURL
echo "$rubySUM $(ls ruby-*.tar.gz)" \
 | sha256sum -c - && tar xzf ruby-*.tar.gz
cd ruby-*/ && ./configure --prefix=$DEVENV/ruby/ && make && make install

echo "Ruby Installed ..."
$DEVENV/ruby/bin/ruby -v

# Installing GO --------------------------------------------------------------#
cd $PKGS; curl --remote-name --progress $goURL
echo "$goSUM $(ls go*linux-amd64.tar.gz)" \
 | sha256sum -c - && tar -C  $DEVENV -xzf go*linux-amd64.tar.gz
#ln -sf $DEVENV/go/bin/{go,godoc,gofmt} /usr/local/bin/

echo "Go Installed ..."
$DEVENV/go/bin/go version

# Installing Node.js ---------------------------------------------------------#
cd $PKGS; curl --remote-name --progress $nodeURL
echo "$nodeSUM $(ls node-*-linux-x64.tar.gz)" \
 | sha256sum -c - && tar -C $DEVENV -xzf node-*-linux-x64.tar.gz 
mv $DEVENV/node{-*-linux-x64,}

echo "Node.js Installed ..."
$DEVENV/node/bin/node -v

# Installing Yarn ------------------------------------------------------------#
cd $PKGS; wget https://yarnpkg.com/latest.tar.gz
tar -C $DEVENV -xzf latest.tar.gz
mv $DEVENV/yarn{-v*,}

echo "Yarn Installed ..."
$DEVENV/yarn/bin/yarn -v

# Installing Redis -----------------------------------------------------------#
cd $PKGS; wget http://download.redis.io/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
mv $PKGS/redis-stable $DEVENV/redis 
#ln -sf $DEVENV/redis/src/{redis-cli,redis-server} /usr/local/bin/

# Configure redis to use sockets
cp -v $DEVENV/redis/redis.conf{,.orig}

# Disable Redis listening on TCP by setting 'port' to 0
sed 's/^port .*/port 0/' $DEVENV/redis/redis.conf.orig | sudo tee $DEVENV/redis/redis.conf

# Enable Redis socket for default Debian / Ubuntu path
echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a $DEVENV/redis/redis.conf

# Grant permission to the socket to all members of the redis group
echo 'unixsocketperm 770' | sudo tee -a $DEVENV/redis/redis.conf

# Create the directory which contains the socket
mkdir /var/run/redis
chown redis:redis /var/run/redis
chmod 755 /var/run/redis

# Persist the directory which contains the socket, if applicable
#if [ -d /etc/tmpfiles.d ]; then
#  echo 'd  /var/run/redis  0755  redis  redis  10d  -' | sudo tee -a /etc/tmpfiles.d/redis.conf
#fi

# Activate the changes to redis.conf
#sudo service redis-server restart

# Add git to the redis group
sudo usermod -aG redis git


# Installing PostgreSQL ------------------------------------------------------#
sh /postgres/postgreSQL.sh


# Git User & Database 
adduser -s /sbin/nologin -c 'GitLab' git

psql -c "CREATE USER git CREATEDB;"
psql -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
psql -c "CREATE DATABASE gitlabhq_production OWNER git;"


# ----------------
for i in $(ls -d /opt/DevEnv/*/bin); do export PATH="$PATH:$i"; echo $PATH; done