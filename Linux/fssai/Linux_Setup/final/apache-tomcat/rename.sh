#!/bin/sh
ID=$1
from=$(ls -lrth /opt/APPS/ | awk "/tom"$ID"/ "'{gsub(/.....$/,"");print $9}')
to=$2
mv -v /opt/APPS/{$from,$to}-tom$ID
sed -i "s/$from-tom$ID/$to-tom$ID/" /etc/systemd/system/tomcat"$ID".service /opt/APPS/$to-tom$ID/bin/server.sh
systemctl daemon-reload