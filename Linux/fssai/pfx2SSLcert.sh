#!/bin/bash
# Usage:
# ./pfx2SSLcert.sh /path/to/domain.pfx
#
# Creates domain.pem and domain.key in the current directory
#
pfxpath="$1"

if [ ! -f "$pfxpath" ];
then
  echo "Cannot find PFX using path '$pfxpath'"
  exit 1
fi

crtname=`basename ${pfxpath%.*}`
domaincacrtpath=`mktemp`
domaincrtpath=`mktemp`
fullcrtpath=`mktemp`
keypath=`mktemp`
passfilepath=`mktemp`
read -s -p "PFX password: " pfxpass
echo -n $pfxpass > $passfilepath

echo "Creating .CRT file"
openssl pkcs12 -in $pfxpath -out $domaincacrtpath -nodes -nokeys -cacerts -passin file:$passfilepath
openssl pkcs12 -in $pfxpath -out $domaincrtpath -nokeys -clcerts -passin file:$passfilepath
cat $domaincrtpath $domaincacrtpath > $fullcrtpath
rm $domaincrtpath $domaincacrtpath

echo "Creating .KEY file"
openssl pkcs12 -in $pfxpath -nocerts -passin file:$passfilepath -passout pass:Password123 \
| openssl rsa -out $keypath -passin pass:Password123

rm $passfilepath

mv $fullcrtpath ./${crtname}.pem
mv $keypath ./${crtname}.key

ls -l ${crtname}.pem ${crtname}.key

read -r -p "Do you want to Update Created SSL ? [y/N] " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        tar -czf sslbkp`date +%H%M%S_%d%b%y`.tgz /opt/apache/conf/ssl/
        cat ${crtname}.pem > /opt/apache/conf/ssl/fssai.pem
        cat ${crtname}.key > /opt/apache/conf/ssl/fssai.key
        
        ;;
    *)
        echo "license no $lic not deleted"

        ;;
esac