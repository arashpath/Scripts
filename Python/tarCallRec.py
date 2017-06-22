#!/usr/bin/python3
#Script Archive Phone Recordings
#Compile Using: pyinstaller --debug --onefile --noupx

from datetime import date,datetime,timedelta
from os import walk,path,remove
from subprocess import call

recDir="/MyData/backUp/MIUI_REC/test/call_rec/"  		   #Phone Recordings Path
tarDir="/MyData/backUp/MIUI_REC/test"                      #Compressed log Path
retain=15 #days                                        #Only Compress logs older then


arcdate = (date.today() - timedelta(retain)).strftime('%Y%m%d')
for dirname, subdir, recordings in walk(recDir):
    for rec in recordings:
        #print (rec, end='')
        #print (rec[-18:-10])
        if arcdate > rec[-18:-10]:
            print (rec)

            """
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
            """