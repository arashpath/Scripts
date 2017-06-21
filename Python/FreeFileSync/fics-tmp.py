from datetime   import date
from calendar   import monthrange
from string     import Template
from datetime   import datetime
from subprocess import call
def add_months(sourcedate,months):
    month = sourcedate.month - 1 + months
    year = int(sourcedate.year + month / 12 )
    month = month % 12 + 1
    day = min(sourcedate.day,monthrange(year,month)[1])
    return date(year,month,day)
	
bkp_month = date(2015,1,1)
present = date.today()

while bkp_month.strftime("%y%m") < present.strftime("%y%m") :
    print "Year: %s , Month: %s" % ( bkp_month.strftime("%Y"), bkp_month.strftime("%b") )
    filein = open( 'fics-tmp.templ' )
    src = Template( filein.read() )
    year = bkp_month.strftime("%Y")
    month = bkp_month.strftime("%b")
    d={ 'year':year, 'month':month }
    result = src.substitute(d)
    ffsbatch = open("fics-tmp.ffs_batch", 'w')
    ffsbatch.write(result)
    ffsbatch.close()
    call(['C:\\Program Files\\FreeFileSync\\FreeFileSync.exe', 'D:\\Scripts\\Temp\\fics-tmp.ffs_batch'])
    bkp_month = add_months(bkp_month,1)


