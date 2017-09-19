PKGS=$(dirname $(readlink -f "$0") )
         cd $PKGS/postgres     ; sh -x postgreSQL.sh &&  \
sleep 2; cd $PKGS/apache-httpd ; sh -x httpd.sh      &&  \
sleep 2; cd $PKGS/php          ; sh -x php.sh        &&  \
sleep 2; cd $PKGS/php          ; sh -x moodle.sh
