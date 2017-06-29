from datetime   import date
from calendar   import monthrange
from string     import Template
from datetime   import datetime
from subprocess import call
from os         import remove

def add_months(sourcedate,months):
    month = sourcedate.month - 1 + months
    year  = int(sourcedate.year + month / 12 )
    month = month % 12 + 1
    day   = min(sourcedate.day,monthrange(year,month)[1])
    return date(year,month,day)
	
bkp_month = date(2015,2,1)
present   = date.today()
##present   = date(2015,1,1)

folders = ['MISDocs','UserImage','LabDocs','AppDocs']

while bkp_month.strftime("%y%m") < present.strftime("%y%m") :
    year = bkp_month.strftime("%Y")
    month = bkp_month.strftime("%b")
    
    print "\nSyncing....  %s, %s" % ( month, year )
    ##raw_input("Press Enter to continue...")
    
    for folder in folders:
        print "  %s" % (folder),
        filein = open( 'fics-tmp.tmpl' )
        src = Template( filein.read() )
        d={ 'year':year, 'month':month, 'folder':folder }
        result = src.substitute(d)
        batch_file = year+month+"_"+folder+".ffs_batch"
        ffsbatch = open( batch_file, 'w')
        ffsbatch.write(result)
        ffsbatch.close()
        
        ##raw_input("Press Enter to continue...")
        ret = call(['C:\\Program Files\\FreeFileSync\\FreeFileSync.exe', batch_file])
        ##ret = 0
        if ret == 0:
            print "\t Done"
        elif ret == 1:
            print "\t Done with Warnings!"
        elif ret == 2:
            print "\t Done with Errors!!"
        elif ret == 3:
            print "\t Aborted!!!"
        
        remove(batch_file)
        
    bkp_month = add_months(bkp_month,1)
    


