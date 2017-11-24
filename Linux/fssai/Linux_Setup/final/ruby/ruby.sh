#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

# Ruby URL
rubyURL="https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.gz"
rubySUM="93b9e75e00b262bc4def6b26b7ae8717efc252c47154abb7392e54357e6c8c9c"

# Installing Ruby ------------------------------------------------------------#
cd $PKGS; curl --remote-name --progress $rubyURL
echo "$rubySUM $(ls ruby-*.tar.gz)" \
 | sha256sum -c - && tar xzf ruby-*.tar.gz
cd ruby-*/ && ./configure --prefix=$DEVENV/ruby/ && make && make install

echo "export PATH=$DEVENV/ruby/bin:\$PATH" >> /opt/DevEnv/dev.env

echo "Ruby Installed ..."
$DEVENV/ruby/bin/ruby -v
