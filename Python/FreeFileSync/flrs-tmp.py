#!/usr/bin/python
from string     import Template
from subprocess import call
from os         import remove
from time       import strftime

#year = ['2016','2015','2017']
year = ['2016']

folders = [
    #['Fdrive/FSSAI-DOCS1/FLRS','CLS'],
    ['Edrive/FSSAI-DOCS/FLRS','SLS'],
    #['Fdrive/FSSAI-DOCS1/FLRS','REG']
    ]
for y in year:
    #for m in range(12,0,-1):
    for m in range(7, 13):
        print "\nSyncing %s %s" %(y, m)
    
        for f in folders:
            drive  = f[0]
            folder = f[1]
            print "%s %s" %(strftime("%H:%M:%S %d/%m/%Y"),folder),

            templ = open( 'flrs-tmp.tmpl' )
            src = Template( templ.read() )
            d={ 'drive':drive, 'folder':folder, 'y':y, 'm':m }
            result = src.substitute(d)
        
            batch_file = "flrs"+folder+"_"+str(y)+str(m)+".ffs_batch"
            ffsbatch = open( batch_file, 'w')
            ffsbatch.write(result)
            ffsbatch.close()

            #raw_input("Press Enter to continue...")
            ret, tr = 1, 1
            while not ret == 0 and tr <= 3:
                    ret = call(['C:\\Program Files\\FreeFileSync\\FreeFileSync.exe', batch_file])
                    tr += 1 
            if ret == 0:
                print "\t Done"
            elif ret == 1:
                raw_input("\t Done with Warnings! Continue..?\n")
            elif ret == 2:
                raw_input("\t Done with Errors!!  Continue..?\n")
            elif ret == 3:
                raw_input("\t Aborted!!!          Continue..?\n")
            
            remove(batch_file)


