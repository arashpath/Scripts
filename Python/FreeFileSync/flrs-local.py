#!/usr/bin/python
from string     import Template
from subprocess import call
from os         import remove
from calendar   import month_name
from time       import strftime

folder_structure = [
    ['2016',
    [
        ['CLS','E:\FSSAI-DOCS\FLRS\CLS2016'],
        ['SLS','E:\FSSAI-DOCS\FLRS\SLS2016'],
        ['REG','E:\FSSAI-DOCS\FLRS\REG2016']
    ]],
    ['2015',
    [
        ['CLS','E:\FSSAI-DOCS\FLRS\CLS\\2015'],
        ['SLS','E:\FSSAI-DOCS\FLRS\SLS'],
        ['REG','E:\FSSAI-DOCS\FLRS\REG\\2015']
    ]]
]

for y in folder_structure:
    for m in range(12, 0, -1):
        print "Syncing... %9s %s" % (month_name[m],y[0])
        for f in y[1]:
            print " %s  %s" % ( strftime("%H:%M:%S %d/%m/%Y"),f[0] ),
            
            templ = open( 'flrs-local.tmpl' )
            src = Template( templ.read() )
            d={ 'year':y[0], 'month':m, 'folder':f[0], 'source':f[1] }
            result = src.substitute(d)

            batch_file = "FLRSlocal_"+y[0]+f[0]+str(m)+".ffs_batch"
            ffsbatch = open( batch_file, 'w')
            ffsbatch.write(result)
            ffsbatch.close()

            
            ret = 0
            ret = call(['C:\\Program Files\\FreeFileSync\\FreeFileSync.exe', batch_file])
    
            if ret == 0:
                print " Done"
            elif ret == 1:
                print " Done with Warnings!"
            elif ret == 2:
                print " Done with Errors!!"
            elif ret == 3:
                print " Aborted!!!"
            

            #raw_input("Press Enter to continue...")
            remove(batch_file)
