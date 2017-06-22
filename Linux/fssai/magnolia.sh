#!/bin/bash
#Bash Script to Change PostgreSQL DB string in Magnolia
Magnolia="/opt/tomcat/webapps/magnolia/"        #Magnolia application Path
DB_Svr="psqldbsvr01"                            #New PostgresDB Host name
DB_Port="5432"                                  #Port 
DB_Name="magdb"                                 #DataBase Name
DB_User="magdbuser"                             #DataBase User 
DB_Pass="magdbpass"                             #DataBase Password
db_url="jdbc:postgresql://$DB_Svr:$DB_Port/$DB_Name"

for i in $(grep -R '<param name="url" value="jdbc:postgresql:' "$Magnolia" -l)
        do sed -i "/<param name=\"url\" value=\"jdbc:postgresql:/s!value=\".*\"!value=\"$db_url\"!" $i
           sed -i "/<param name=\"user\"/s/value=\".*\"/value=\"$DB_User\"/" $i
           sed -i "/<param name=\"password\"/s/value=\".*\"/value=\"$DB_Pass\"/" $i
done
