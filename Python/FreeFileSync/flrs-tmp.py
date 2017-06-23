#!/usr/bin/python
from string     import Template
from subprocess import call
from os         import remove

months  = ['6','5','4','3','2','1']
folders = [ ['Fdrive/FSSAI-DOCS1/FLRS','CLS'],
            ['Edrive/FSSAI-DOCS/FLRS','SLS'],
            ['Fdrive/FSSAI-DOCS1/FLRS','REG']  ]

for m in months:
    print "\nSyncing 2017"
    
    for f in folders:
        drive  = f[0]
        folder = f[1]
        print " %s\t" %(folder),

        templ = open( 'flrs-tmp.tmpl' )
        src = Template( templ.read() )
        d={ 'drive':drive, 'folder':folder, 'm':m }
        result = src.substitute(d)
        
        batch_file = "flrs-"+folder+"_"+m+".ffs_batch"
        ffsbatch = open( batch_file, 'w')
        ffsbatch.write(result)
        ffsbatch.close()

        raw_input("Press Enter to continue...")
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


