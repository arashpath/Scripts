import os
import pyodbc

mssql = pyodbc.connect(
    r'DRIVER={SQL Server};'
    r'SERVER=192.168.11.201;'
    r'DATABASE=FLRS;'
    r'UID=sa;PWD=SAflrs@123').cursor()   #LocalDB

sql_query = """select top 50 REFID, DOCLocation, TableName FROM (
          select REFID, DOCLocation, 'LM_CL_FBO_Documents'			as TableName from LM_CL_FBO_Documents
    union select REFID, DOCLocation, 'LM_CL_FBO_Documents_Log'		as TableName from LM_CL_FBO_Documents_Log
    union select REFID, DOCLocation, 'CL_FBO_Documents'				as TableName from CL_FBO_Documents
    union select REFID, DOCLocation, 'CL_FBO_DocumentChange_log'	as TableName from CL_FBO_DocumentChange_log
    union select REFID, DOCLocation, 'CL_FBO_PADocument'			as TableName from CL_FBO_PADocument
    union select REFID, DOCLocation, 'CL_FBO_PADocumentChange_LOG'	as TableName from CL_FBO_PADocumentChange_LOG
 ) AS AllDocs_CLS where DocLocation is not null order by REFID
"""
mssql.execute(sql_query)
rows = mssql.fetchall()

base_path = r'D:\FSSAI_DOCS\FLRS'
doc_type  = 'CLS'

for row in rows:
    zero_file = row.DOCLocation
    file_path = os.path.join(base_path, doc_type, os.path.normpath(zero_file) )
    if not os.path.exists(os.path.dirname(file_path)):
        os.makedirs(os.path.dirname(file_path))

    open(file_path,'a').close()
