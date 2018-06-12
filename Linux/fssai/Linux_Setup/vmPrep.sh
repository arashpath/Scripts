#!/bin/bash
# -*- coding: utf-8 -*-

# Disable SE Linux & Firewall ------------------------------------------------#
systemctl disable firewalld
sed -i 's/=enforcing/=disabled/' /etc/selinux/config

# Configure Yum (Disable all Rebo and Use Mounted CD Only) -------------------#
mkdir /media/CentOS
echo "/dev/sr0       /media/CentOS       iso9660 ro       0 0 " >> /etc/fstab 
mount -a

sed -i '/\[base\]/,/^\[.*\]$/{s/^$/enabled=0\n/}
/\[updates\]/,/^\[.*\]$/{s/^$/enabled=0\n/}
/\[extras\]/,/^\[.*\]$/{s/^$/enabled=0\n/}' /etc/yum.repos.d/CentOS-Base.repo

sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-Media.repo

yum clean all
yum repolist

# History with Timestamp
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile

# REBOOT Server and check Selinux

#========================== Making A Linux Template ==========================#
systemctl stop rsyslog
systemctl stop auditd
yum clean all

logrotate -f /etc/logrotate.conf

rm -vf /var/log/*-???????? /var/log/*.gz /var/log/dmesg.old

/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

/bin/rm -vf /etc/udev/rules.d/70*

/bin/sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-ens192 

rm -rvf /tmp/*
rm -rvf /var/tmp/*
rm -vf /etc/ssh/*key*  
rm -rvf ~root/.ssh/
rm -vf ~root/anaconda-ks.cfg
rm -vf ~root/.bash_history
unset HISTFILE


dd if=/dev/zero of=/ZERO
rm -vf /ZERO
poweroff