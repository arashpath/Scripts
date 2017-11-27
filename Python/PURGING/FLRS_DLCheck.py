import os
import pyodbc
#import pypyodbc as pyodbc

cnxnStr = (  r'DRIVER={SQL Server};DATABASE=FLRS;'
    r'SERVER=192.168.11.201;UID=sa;PWD=SAflrs@123'      #LocalDB

    )
cnxn   = pyodbc.connect(cnxnStr)
mssql  = cnxn.cursor()
SELECT = "select * from Purging_log where [Status] <> 'Downloaded' and LicType = ?"
UPDATE = """update Purging_log set [Status] = 'Downloaded' 
            where LicType = ? and TableName = ? and DOC = ? """
print 'Getting Rows..'
xcute = mssql.execute(SELECT, 'CLS')
base_path = r'D:\FSSAI-DOCS\FLRS'
files_found     = 0
values = []
rows = xcute.fetchall()


def update(values):
    try:
        mssql.executemany(UPDATE, values)
    except pyodbc.Error as dberr:
        print "UpdateError: "+str(dberr)
    finally:
        mssql.commit()

for row in rows:
    if os.path.isfile( os.path.join( base_path,
                       row.LicType, os.path.normpath(row.DOC)) ):
        files_found += 1
        values += [(row.LicType, row.TableName, row.DOC)]    
    print '\r{:<9} found ({}/{})\r'.format(files_found, 
                                       rows.index(row)+1 , len(rows)),
cnxn.close()
