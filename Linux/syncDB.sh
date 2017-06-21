DB=$1

PROX="/bin/ssh -t web01main"
DBSVR=psqldb01

getAl="$PROX ssh root@$DBSVR 'pg_dumpall -c -U postgres'"
lstAl="$PROX ssh root@$DBSVR 'psql -U postgres -lqt'"
getDB="$PROX ssh root@$DBSVR 'pg_dump -U postgres -cC $DB'"

if [ $DB = all ]; then
	echo "Closing All Connections......"
	psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity"
	echo "Syncing all DBs......"
	eval $getAl | psql

elif  eval $lstAl | cut -d \| -f 1 | grep -qw $1 ; then  
	echo "Closing All Connections for  $DB DB......"
	psql -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity
		WHERE datname = '$DB';"
	echo "Syncing  $DB DB......"
	eval $getDB | psql

else
	echo "Usage \"syncDB.sh [all|DBNAME]\""
	echo "Avillable DBNAME from following table"
	eval $lstAl
fi
