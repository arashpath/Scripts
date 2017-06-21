Magnolia="/opt/APPS/default-tom0/webapps/ROOT/"
#DB Server:	OldSvr="localhost" ; NewSvr="postgresql"
Svr_o="psqldb01" ; Svr_n="psqldb01"
#DB Name:	OldDB="fssai-demo" ; NewDB="fssaimain"
DB_o="fssaimain" ; DB_n="fssaimain"
#DBUser
for i in $(grep -R jdbc:postgresql://$Svr_o:5432/$DB_o "$Magnolia" -l)
	do sed -i "/jdbc:postgresql:\/\/$Svr_o:5432\/$DB_o/ 	{
		s/$Svr_o/$Svr_o/
		s/$DB_o/$DB_o/	}" $i
done
