echo "Taking BackUp.."
ssh root@117.239.180.188 "tar -czf /data/BKP/diet4life150451-30Mar17.tgz /var/www/html/diet4life/"
rsync -aP /opt/APPS/diet4life_html/ root@117.239.180.188:/var/www/html/diet4life/
