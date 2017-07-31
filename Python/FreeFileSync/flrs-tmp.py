#!/usr/bin/python
from string     import Template
from subprocess import call
from os         import remove
from time       import strftime
from sys        import argv

# Function To Create a ffs_batch and run FreeFileSync
def run_ffs(folders,y='',m='',exclude=''):
    """ A function to Run FFS"""
    for f in folders.keys():
        print "%s %s" %(strftime("%H:%M:%S %d/%m/%Y"),f),

        templ = open( 'flrs-tmp.tmpl' )
        src = Template( templ.read() )
        d={ 'drive':folders.get(f), 'folder':f, 'y':y, 'm':m, 'exclude':exclude }
        result = src.substitute(d)

        batch_file = "flrs"+f+str(y)+str(m)+".ffs_batch"
        with open( batch_file, 'w') as ffsbatch:
            ffsbatch.write(result)

        #raw_input("Press Enter to continue...")
        ret, tr = 1, 1
        while not ret == 0 and tr <= 3:
                ret = call(['C:\\Program Files\\FreeFileSync\\FreeFileSync.exe', batch_file])
                tr += 1 
        if ret == 0:
            print "=>> Done"
        elif ret == 1:
            print "=>> Done with Warnings!" , raw_input("\t Continue..?\n")
        elif ret == 2:
            print "=>> Done with Errors!!"  , raw_input("\t Continue..?\n")
        elif ret == 3:
            print "=>> Aborted!!!      "    , raw_input("\t Continue..?\n")

        remove(batch_file)


# Define Folders and their Base path
folders = {
    'CLS':'Fdrive/FSSAI-DOCS1/FLRS',
    'SLS':'Edrive/FSSAI-DOCS/FLRS', 
    'REG':'Fdrive/FSSAI-DOCS1/FLRS'
    }

# Def Years
year = ['2015','2016','2017']

if len(argv) >= 2:
    folders = { argv[1] : folders.get(argv[1]) }

#Sync Base
ex = r"""
                <Item>\2015\</Item>
                <Item>\2016\</Item>
                <Item>\2017\</Item>
"""
print "\nSyncing Base Folder"
run_ffs(folders,exclude=ex) 

for y in year:
    for m in range(1,13):
        print "\nSyncing %s %s" %(y, m)
        run_ffs(folders,y,m)