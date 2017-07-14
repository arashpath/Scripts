DECLARE @name VARCHAR(50)		-- database name  
DECLARE @path VARCHAR(256)		-- path for backup files  
DECLARE @fileName VARCHAR(256)	-- filename for backup  
DECLARE @fileDate VARCHAR(20)	-- used for file name
 
-- specify database backup directory
SELECT @path = 'C:\FSSAI\All_DBbkp_'+CONVERT(VARCHAR(20),GETDATE(),112) 

 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) +'_'+ REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb')  
	and name not like 'ReportServer$SQLEXPRESS%' -- exclude these databases
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor