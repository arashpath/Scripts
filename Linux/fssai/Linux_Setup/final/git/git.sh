#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

# Git URL 
 gitURL="https://www.kernel.org/pub/software/scm/git/git-2.15.0.tar.gz"
 gitSUM="25762cc50103a6a0665c46ea33ceb0578eee01c19b6a08fd393e8608ccbdb3da" 

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

echo "export PATH=$DEVENV/git/bin:\$PATH" >> /opt/DevEnv/dev.env

echo "Git Installed ..."
$DEVENV/git/bin/git --version
