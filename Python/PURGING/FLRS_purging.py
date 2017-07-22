import pyodbc
import os
from humanbytes import hb


mssql = pyodbc.connect('DRIVER={SQL Server};SERVER=192.168.11.201;DATABASE=FLRS;UID=sa;PWD=SAflrs@123').cursor()


arcLoc = 'G:\PURGED_DOCS\FLRS'

purgeFiles = [
    ['CLS', 'F:\FSSAI-DOCS1\FLRS'],
    ['SLS', 'E:\FSSAI-DOCS\FLRS'],
    ['REG', 'F:\FSSAI-DOCS1\FLRS']   
] 

all_sum = 0
for p in purgeFiles:
    (doc_type, base_path) = p
    base_path = 'D:\FSSAI-DOCS\FLRS' #OverRide Actual base path for local testing
    sql_query = "SELECT [refid], [PATH], [issueddate], [ExpireDate] FROM FLRS.dbo.EXPLICDATA WHERE [TYPE] = '"+doc_type+"' AND [PATH] is NOT NULL ORDER BY [ExpireDate], [refid]"
    mssql.execute(sql_query)
    rows = mssql.fetchall()

    with open(doc_type+'_purging.log','w') as log_file:
        doc_sum = 0
        for row in rows:
            arcFile = os.path.normpath(row.PATH)
            srcPath = os.path.join(base_path, doc_type, arcFile) 
            arcPath = os.path.join(arcLoc, doc_type, arcFile)
            #print ("Moving from: "+srcPath+"\n\t to: "+arcPath)
            if os.path.isfile(srcPath):
                f = os.path.getsize(srcPath)
                #os.renames(srcPath,arcPath)
                #print ("Archived: %s "+arcFile)
                doc_sum = doc_sum + f
                print (hb(doc_sum)+" Found\t: "+srcPath, file=log_file)
            else:
                print ("File Not Found\t: "+srcPath, file=log_file)

        print (30*"=", file=log_file)
        print ("Grand Total of "+doc_type+" = "+hb(doc_sum), file=log_file)
        print (30*"=", file=log_file)

    all_sum = all_sum + doc_sum
    input (hb(doc_sum)+" cleared in "+doc_type+"Enter to continue...")

print ("Total Space Saved After Purging : "+hb(all_sum))