systemctl enable sshd.service 
systemctl start sshd.service

cp /etc/ssh/sshd_config{,_org}

sed -i '/^Subsystem/ {
	s/^/#/
	a Subsystem sftp internal-sftp 
}' /etc/ssh/sshd_config 

cat <<EOF >> /etc/ssh/sshd_config

# sFTP Configuration
Match Group sftponly 
ChrootDirectory %h 
ForceCommand internal-sftp 
X11Forwarding no 
AllowTcpForwarding no

EOF

systemctl restart sshd.service

groupadd sftponly 
useradd foscoris -g sftponly -s /bin/false
passwd foscoris

fosc0123



chown root /home/foscoris
chmod 755 /home/foscoris
mv /opt/APPS/foscoris{,_bak}

mkdir /home/foscoris/www /opt/APPS/foscoris
mount --bind /opt/APPS/foscoris /home/foscoris/www
chown foscoris /home/foscoris/www
chmod 755 /home/foscoris/www
