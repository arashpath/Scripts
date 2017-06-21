#Script To Zip IIS LogFiles
#Compile Using: pyinstaller --debug --onefile --noupx

from datetime import date,datetime,timedelta
from os import walk,path,remove
from zipfile import ZipFile,ZIP_DEFLATED
from socket import gethostbyname, gethostname

logDir="C:\inetpub\logs\LogFiles"  		   #IIS logs  Path
zipDir="//10.248.169.201/PrDL/IISLogs"     #Compressed log Path
retain=5 #days                             #Only Compress logs older then


IP = "_"+gethostbyname(gethostname()).split(".")[3]+"_"

arcdate = (date.today() - timedelta(retain)).strftime('%y%m%d')
for dirname, subdir, logs in walk(logDir):
    for log in logs:
        if arcdate > log[4:-4]:
            logFile = path.abspath(path.join(dirname,log))
            zFile = log[4:-6]+IP+path.basename(path.dirname(dirname))+".zip"
            zPath = path.join(zipDir,zFile)
            #arcFile = logFile[len(path.abspath(logDir)) +1:]
            ziplog = open("%s/iisCompress.log" % (zipDir), "a")
            print >>ziplog, "%s: Compressing %s to %s" % (datetime.now(),
                                                path.join(dirname,log),
                                                zFile)
            ziplog.close()
            z = ZipFile(zPath,"a",ZIP_DEFLATED)
            z.write(logFile,log)
            z.close()
            remove(logFile)