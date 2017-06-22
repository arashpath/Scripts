#!/bin/bash
#Script to Change Pos DB string in Magnolia
Magnolia="/opt/APPS/mainHI-tom6/webapps/ROOT/"
DB_Svr="psqldbsvr01"
DB_Port="5432"
DB_Name="magdb"
DB_User="magdbuser"
DB_Pass="magdbpass"
db_url="jdbc:postgresql://$DB_Svr:$DB_Port/$DB_Name"

for i in $(grep -R '<param name="url" value="jdbc:postgresql:' "$Magnolia" -l)
        do sed -i "/<param name=\"url\" value=\"jdbc:postgresql:/s!value=\".*\"!value=\"$db_url\"!" $i
           sed -i "/<param name=\"user\"/s/value=\".*\"/value=\"$DB_User\"/" $i
           sed -i "/<param name=\"password\"/s/value=\".*\"/value=\"$DB_Pass\"/" $i
done
