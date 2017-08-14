from ffs_batch  import gen, run
from datetime   import date
from calendar   import monthrange

def add_months(sourcedate,months):
    month = sourcedate.month - 1 + months
    year  = int(sourcedate.year + month / 12 )
    month = month % 12 + 1
    day   = min(sourcedate.day,monthrange(year,month)[1])
    return date(year,month,day)
	
bkp_month = date(2015,2,1)
present   = date.today()    ##present   = date(2015,1,1)
folders = ['MISDocs','UserImage','LabDocs','AppDocs']

while bkp_month.strftime("%y%m") < present.strftime("%y%m") :
    year = bkp_month.strftime("%Y")
    month = bkp_month.strftime("%b")    
    print "\nSyncing....  %s, %s" % ( month, year )
    for folder in folders:
        print "  %s" % (folder),
        source = ('ftp://administrator@10.248.169.197'
            '/Edrive/FSSAI-DOCS/ICS/writereaddata/{}/{}/{}'
            #PASSWORD
            ).format(folder, year, month)
        destin = (r'D:\FSSAI-DOCS\FICS\writereaddata\{}\{}\{}'
            ).format(folder, year, month)
        run(gen(year+month+"_"+folder, source, destin, logpath=r'D:\Scripts\Temp\FICS\synclog'))        
    bkp_month = add_months(bkp_month,1)