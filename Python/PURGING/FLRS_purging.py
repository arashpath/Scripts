import pyodbc
import os
from humanbytes import hb


mssql = pyodbc.connect('DRIVER={SQL Server};SERVER=192.168.11.201;DATABASE=FLRS;UID=sa;PWD=SAflrs@123').cursor()


arcLoc = 'G:\PURGED_DOCS\FLRS'
### arcLoc = 'D:\FSSAI_DOCS\DSC'
purgeFiles = (
    ['CLS', 'F:\FSSAI-DOCS1\FLRS'],
    ['SLS', 'E:\FSSAI-DOCS\FLRS'],
    ['REG', 'F:\FSSAI-DOCS1\FLRS']   
)
 

for p in purgeFiles:
    (doc_type, base_path) = p
    sql_query = "SELECT [refid], [PATH], [issueddate], [ExpireDate] FROM FLRS.dbo.EXPLICDATA WHERE [TYPE] = '"+doc_type+"' AND [PATH] is NOT NULL ORDER BY [ExpireDate], [refid]"
    mssql.execute(sql_query)
    rows = mssql.fetchall()
    sum = 0 
    for row in rows:
        arcFile = os.path.normpath(row.PATH)
        srcPath = os.path.join(base_path, doc_type, arcFile) 
        arcPath = os.path.join(arcLoc, doc_type, arcFile)
        print ("Moving from: "+srcPath+"\n\t to: "+arcPath)
        if os.path.isfile(srcPath):
            f = os.path.getsize(srcPath)
            #os.renames(srcPath,arcPath)
            print ("Archived: %s "+arcFile)
            sum = sum + f
    print (hb(sum))
