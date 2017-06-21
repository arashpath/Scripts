#!/bin/bash
from=$1
to=$2
svr=`echo $to | cut -d: -f1`
dest=`echo $to | cut -d: -f2`
echo $dest
rsync -ain $from $to | awk '/^<f*+/{print $2}' | ssh $svr 'xargs tar -czvf /opt/BKPs/backp`date +%H%M%S_%d%b%y`.tgz'
#| sed 's/^/\/opt\/APPS\//'| ssh $svr 'xargs tar -czvf /opt/BKPs/backp`date +%H%M%S_%d%b%y`.tgz'
