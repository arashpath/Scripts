# #Compile Using: pyinstaller --debug --onefile --noupx

import pypyodbc as pyodbc 
import os
import pickle
from purging     import hb, fs_check
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
    except pyodbc.Error as dberr :
        print str(values)+"\n MSSQL InsertError: "+str(dberr)
    finally:
        mssql.commit()

def do_purg( base_path, rows, arcLoc = r'G:\PURGED_DOCS\FLRS' ):
    doc_sum, row_count = 0, 0
    if not rows:
        print "{0} Hooray!!!  No Need to purge this {0}".format(23*'-')
        return doc_sum
    widgets = [Counter(), Bar(marker=RotatingMarker()), Timer()]
    pbar = ProgressBar(widgets=widgets)
    for row in pbar(rows):
        if not fs_check(5,'G'):
            print "\n{0}< SPACE FULL !!! >{0}".format(31*'-')
            try:
                with open(row.LicType+'_pending.pickle', 'wb') as pending_rows:
                    pickle.dump( rows[row_count:]  ,pending_rows)
            except IOError as ioerr:
                print "FileErroe: "+str(ioerr)
            except pickle.PickleError as perr:
                print "PicklingError: "+str(perr)
            return doc_sum
        else:
            arcFile = os.path.normpath(row.DOC)
            srcPath = os.path.join(base_path, arcFile)
            arcPath = os.path.join(arcLoc, row.LicType, arcFile)
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
    print "{1}>> Space Cleared : {0:>10} <<{1}".format(hb(doc_sum), 24*'-')
    return doc_sum

sql_sp = "exec FLRS.dbo.PurgingDOC "  

print "Getting Expired Lic Count..."
total_space_cleared = 0
for each in mssql.execute(sql_sp+'getCount ').fetchall():
    print "Now Purging '{}' From {:>24}".format(each.LicType, each.BasePath)
    pickle_file = each.LicType+'_pending.pickle'
    try:                    
        if os.path.isfile(os.path.join(os.getcwd(), pickle_file)):
            rows = pickle.load( open(pickle_file, 'rb') )
        else:
            rows = mssql.execute(sql_sp+"get"+each.LicType).fetchall()
    except IOError as err:
        print 'FileError: '+str(err)
    except pickle.PickleError as perr:
        print 'PickleReadError: '+str(perr)
    except pyodbc.Error as dberr:
        print 'MSSQL FetchError: '+str(dberr)
    space_cleared = do_purg( each.BasePath, rows )
    total_space_cleared += space_cleared
cnxn.close()
print 80*'='
print 23*'>'+" Total Space Cleared : {:>10} ".format(
    hb(total_space_cleared))+23*'<'
print 80*'='