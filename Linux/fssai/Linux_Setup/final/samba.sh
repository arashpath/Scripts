yum -y install samba samba-client samba-common
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak

cat << EOF > /etc/samba/smb.conf    
[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = centos
security = user
map to guest = bad user
dns proxy = no
allow insecure wide links = yes
# Share Folders ===========#
[StgSites]
path = /opt/APPS
valid users = @smbgrp
guest ok = no
writable = yes
browsable = yes
follow symlinks = yes
wide links = yes
EOF

groupadd smbgrp
useradd -s /sbin/nologin dev -G smbgrp
(echo dev@123; echo dev@123) | smbpasswd -a -s dev
chown -R dev:smbgrp /opt/APPS
systemctl restart smb.service
systemctl restart nmb.service
