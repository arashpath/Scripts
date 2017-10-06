#!/bin/bash

# Getting Domain Details
svr='snfportal' ; com='in'
echo "Enter Desired Domain:"
#echo "DomineName (dc=svr)?:"; read $svr
#echo "TLD Domain (dc=com)?:"; read $com

#1 Install OpenLDAP Server. ================================================= # 
echo "=========================== Install OpenLDAP Server\
 ==========================="
yum -y install openldap-servers openldap-clients 
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG 
chown ldap. /var/lib/ldap/DB_CONFIG 

systemctl start slapd 
systemctl enable slapd 


#2 Set OpenLDAP admin password. ============================================= #
echo "========================= Set OpenLDAP Admin Password\
 ========================="
cat << EOF > chrootpw.ldif
# specify the password generated above for 'olcRootPW' section
dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: 

EOF

echo "Enter Admin Passwd :"
sed -i "s,^olcRootPW:.*$,olcRootPW: $(slappasswd)," chrootpw.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f chrootpw.ldif

#3 Import basic Schemas. ==================================================== #
echo "============================= Import Basic Schemas\
 ============================="
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif 

#4 Set your domain name on LDAP DB. ========================================= #
echo "======================= Set Your Domain Name on LDAP DB\
 ======================="
cat << EOF > chdomain.ldif
# replace to your own domain name for "dc=***,dc=***" section
# specify the password generated above for "olcRootPW" section

dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth"
  read by dn.base="cn=Manager,dc=fssai,dc=world" read by * none

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=fssai,dc=world

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=Manager,dc=fssai,dc=world

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcRootPW
olcRootPW: 

dn: olcDatabase={2}hdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {0}to attrs=userPassword,shadowLastChange by
  dn="cn=Manager,dc=fssai,dc=world" write by anonymous auth by self write by * none
olcAccess: {1}to dn.base="" by * read
olcAccess: {2}to * by dn="cn=Manager,dc=fssai,dc=world" write by * read

EOF

sed -i "s/dc=fssai,dc=world/dc=$svr,dc=$com/" chdomain.ldif
echo "Enter Domine Manager Passwd :"
sed -i "s,^olcRootPW:.*$,olcRootPW: $(slappasswd)," chdomain.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f chdomain.ldif 


cat << EOF > basedomain.ldif
# replace to your own domain name for "dc=***,dc=***" section

dn: dc=fssai,dc=world
objectClass: top
objectClass: dcObject
objectclass: organization
o: fssai world
dc: fssai

dn: cn=Manager,dc=fssai,dc=world
objectClass: organizationalRole
cn: Manager
description: Directory Manager

dn: ou=People,dc=fssai,dc=world
objectClass: organizationalUnit
ou: People

dn: ou=Group,dc=fssai,dc=world
objectClass: organizationalUnit
ou: Group

EOF

sed -i "s/dc=fssai,dc=world/dc=$svr,dc=$com/
        s/^o: fssai world$/o: $svr $com/
        s/^dc: fssai$/dc: $svr/" basedomain.ldif
ldapadd -x -D cn=Manager,dc=$svr,dc=$com -W -f basedomain.ldif 
