#!/bin/bash
#Script to backup from Live Database on Local Server
DB=$1
#DBSVR=$2
DBSVR="psqldb01"
#DBSVR="psqlsnfdb"
#exec 2> /dev/null

if [ $DB = all ]; then
	echo "===== Starting Full Backup  $(date +%c)  ====="
	/bin/ssh -t web01main ssh root@$DBSVR 'pg_dumpall -c -U postgres | gzip' \
	    > /opt/liveBKP/PGallDB-`date +%d%b%y`.sql.gz
	echo "===== Completed Full Backup $(date +%c)  ====="

elif /bin/ssh -t web01main root@$DBSVR 'psql -U postgres -lqt' \
| cut -d \| -f 1 | grep -qw $1 ; then  
	echo "========= Starting $DB DB Backup  $(date +%c) ========"
	/bin/ssh -t web01main ssh root@$DBSVR "pg_dump -U postgres -cC $DB | gzip" \
	    > /opt/liveBKP/$DB-`date +%d%b%y`.sql.gz
	echo "===== Bkp Completed $(date +%c) ====="

else
	echo "Usage \"bkpDB.sh [all|DBNAME]\""
	echo "Avillable DBNAME from following table"
	/bin/ssh -t web01main ssh root@$DBSVR 'psql -U postgres -l'
fi
