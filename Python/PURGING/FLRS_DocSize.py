# #Compile Using: pyinstaller --debug --onefile --noupx

import pyodbc
import os
from humanbytes  import hb
from progressbar import Bar, Percentage, ProgressBar


#DataBase Connection String
mssql = pyodbc.connect(
    r'DRIVER={SQL Server};DATABASE=FLRS;'
    #r'SERVER=192.168.11.201;UID=sa;PWD=SAflrs@123' #LocalDB

    ).cursor()   

(doc_type, base_path) = ['CLS', r'F:\FSSAI-DOCS1\FLRS']
sql_query = """select A.REFID, L.IssuedDate, L.ExpireDate, A.DOCLocation, A.TableName FROM (
	      select REFID, DOCLocation, 'LM_CL_FBO_Documents'			as TableName from LM_CL_FBO_Documents
	union select REFID, DOCLocation, 'LM_CL_FBO_Documents_Log'		as TableName from LM_CL_FBO_Documents_Log
	union select REFID, DOCLocation, 'CL_FBO_Documents'				as TableName from CL_FBO_Documents
	union select REFID, DOCLocation, 'CL_FBO_DocumentChange_log'	as TableName from CL_FBO_DocumentChange_log
	union select REFID, DOCLocation, 'CL_FBO_PADocument'			as TableName from CL_FBO_PADocument
	union select REFID, DOCLocation, 'CL_FBO_PADocumentChange_LOG'	as TableName from CL_FBO_PADocumentChange_LOG
	) AS A 
	left join CL_FBO_License as L on A.REFID = L.REFID

	where	A.DocLocation is not null 
		and convert(date,L.ExpireDate) < convert(date,getdate())
order by L.ExpireDate
"""
mssql.execute(sql_query)
rows = mssql.fetchall()

with open(doc_type+'_notfound.log', 'w') as not_log, open(doc_type+'_purging.log', 'w') as purg_log:
    doc_sum = 0
    pbar = ProgressBar(widgets=[hb(doc_sum),Bar(),Percentage()])
    for row in pbar(rows):
        srcPath = os.path.join(base_path, doc_type, os.path.normpath(row.DOCLocation))
        try:
            if os.path.isfile(srcPath):
                f = os.path.getsize(srcPath)
                doc_sum = doc_sum + f
                print >>purg_log, srcPath 
            else:
                print >>not_log, srcPath
        except UnicodeError:
            print "Error While Processing %s" % (srcPath)

    
print 30*"="
print "Grand Total of %s  = %s" % (doc_type,  hb(doc_sum))
print 30*"="