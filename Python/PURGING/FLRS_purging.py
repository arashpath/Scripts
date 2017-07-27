# #Compile Using: pyinstaller --debug --onefile --noupx

import pyodbc
import os
from humanbytes import hb

#DataBase Connection String
mssql = pyodbc.connect(
    r'DRIVER={SQL Server};'
    r'SERVER=192.168.11.201;'
    r'DATABASE=FLRS;'
    r'UID=sa;PWD=SAflrs@123').cursor()   #LocalDB

arcLoc = r'G:\PURGED_DOCS\FLRS'

purgeFiles = [
    ['CLS', r'F:\FSSAI-DOCS1\FLRS'],
    ['SLS', r'E:\FSSAI-DOCS\FLRS'],
    ['REG', r'F:\FSSAI-DOCS1\FLRS']   
] 

all_sum = 0
for p in purgeFiles:
    (doc_type, base_path) = p
    #base_path = 'D:\FSSAI-DOCS\FLRS' #OverRide Actual base path for local testing
    sql_query = "exec FLRS.dbo.PurgingDOC ?"
    mssql.execute(sql_query, 'get'+doc_type)
    rows = mssql.fetchall()

    with open(doc_type+'_purging.log', 'w') as log_file:
        doc_sum = 0
        for row in rows:
            arcFile = os.path.normpath(row.PATH)
            srcPath = os.path.join(base_path, doc_type, arcFile)
            arcPath = os.path.join(arcLoc, doc_type, arcFile)
            #print ("Moving from: "+srcPath+"\n\t to: "+arcPath)

            try:
                if os.path.isfile(srcPath):
                    f = os.path.getsize(srcPath)
                    #os.renames(srcPath,arcPath)
                    #print ("Archived: %s "+arcFile)
                    doc_sum = doc_sum + f
                    print >>log_file, "%s Found\t: %s" % ( hb(doc_sum), srcPath ) 
                else:
                    print >>log_file, "File Not Found\t: %s" % (srcPath)
            except UnicodeError:
                print "Error While Logging %s" % (srcPath)

        print >>log_file, 30*"="
        print >>log_file, "Grand Total of %s  = %s" % (doc_type,  hb(doc_sum))
        print >>log_file, 30*"="

    all_sum = all_sum + doc_sum
    print "%s Will be cleared in %s " % (hb(doc_sum), doc_type)
    #raw_input("Cont.")

print "Total Space Saved After Purging : %s" % (hb(all_sum))
