# #Compile Using: pyinstaller --debug --onefile --noupx

import pyodbc
import os
import pickle
from purging  import hb, fs_check
from progressbar import ProgressBar, Bar, Counter, Timer, RotatingMarker


#DataBase Connection String
cnxn = pyodbc.connect(
    r'DRIVER={SQL Server};DATABASE=FLRS;'
    r'SERVER=192.168.11.201;UID=sa;PWD=SAflrs@123' #LocalDB
    )
mssql = cnxn.cursor()

def insert(row, status):
    values = list(row)
    'INSERT QUERY FOR PURGING LOG'
    insert_query ='''INSERT INTO [dbo].[Purging_log] (
        [LicType],[REFID],[IssuedDate],[ExpireDate],[DOC],[TableName],
        [Status]) VALUES (?,?,?,?,?,?,?) ;'''
    values.append(status)
    try:
        mssql.execute(insert_query, values)
    except pyodbc.Error as pyerr :
        print "MSSQLError: "+str(pyerr)
    finally:
        mssql.commit()

def do_purg( doc_type, base_path, rows, arcLoc = r'G:\PURGED_DOCS\FLRS' ):
    print "Purging "+doc_type
    doc_sum, row_count = 0, 0
    widgets = [Counter(), Bar(marker=RotatingMarker()), Timer()]
    pbar = ProgressBar(widgets=widgets)
    for row in pbar(rows):
        if not fs_check(5,'G'):
            print "\n Space Full !!"
            with open(doc_type+'_pending.pickle', 'wb') as pending_rows:
                pickle.dump( rows[row_count:]  ,pending_rows)
            return doc_sum
        else:
            arcFile = os.path.normpath(row.DOC)
            srcPath = os.path.join(base_path, doc_type, arcFile)
            arcPath = os.path.join(arcLoc, doc_type, arcFile)
            try:
                if os.path.isfile(srcPath):
                    fsize = os.path.getsize(srcPath)
                    os.renames(srcPath, arcPath)
                    doc_sum += fsize
                    status = "Moved"
                else:
                    status = "NotFound"
            except IOError as ioerr:
                print "FileError: "+str(ioerr)
                status = "ERROR"
            insert(row, status)
            row_count += 1   
    print 80*"-"
    print "Total Space Cleared in %s = %s" % (doc_type,  hb(doc_sum))
    print 80*"-"
    return doc_sum

sql_sp = "exec FLRS.dbo.PurgingDOC "  

print "Getting Expired Lic Count..."
total_space_cleared = 0
for each in mssql.execute(sql_sp+'getCount').fetchall():
    pickle_file = each.LicType+'_pending.pickle'
    print "{} Total Lic: {} Expired Lic: {}".format(each.LicType, each.Total, 
                                                    each.Expired)
    if os.path.isfile(os.path.join(os.getcwd(), pickle_file)):
        rows = pickle.load( open(pickle_file, 'rb') )
    else:
        rows = mssql.execute(sql_sp+"get"+each.LicType).fetchall()
    space_cleared = do_purg( each.LicType, each.BasePath, rows )
cnxn.close()
print 80*"="
print "Total Space Cleared : {} ".format(hb(total_space_cleared))
print 80*"="