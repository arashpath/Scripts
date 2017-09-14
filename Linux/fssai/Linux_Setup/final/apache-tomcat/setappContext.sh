set -e
ID=$1
path=`ls -d /opt/APPS/*-tom$ID`
app=`cd /opt/APPS/*-tom$ID/webapps/; find -maxdepth 1 -type d | sed -n '$s/\.\///p'`
sed -i  "$!N;s/^.*\n.*<\/Host>/\n\t<Context\ path=\"\" docBase=\"$app\"\/>\n&/" $path/conf/server.xml
