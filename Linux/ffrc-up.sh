ssh root@web01main '/bin/tar -czf /opt/BKPs/fortification-`date +%d%b%y_%H%M%S`.tgz /opt/APPS/ffrc-tom1/webapps/fortification' \
&& rsync -aP /opt/APPS/ffrc-tom1/webapps/fortification/ root@web01main:/opt/APPS/ffrc-tom1/webapps/fortification
