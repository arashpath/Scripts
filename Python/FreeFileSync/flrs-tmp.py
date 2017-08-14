#!/usr/bin/python
from ffs_batch  import gen, run
from time       import strftime
from sys        import argv

# Function To Create a ffs_batch and run FreeFileSync
def run_ffs(folders,y='',m='',exclude=''):
    """ A function to Run FFS"""
    for f in folders.keys():
        print "%s %s" %(strftime("%H:%M:%S %d/%m/%Y"),f),
        source = (
            'ftp://administrator@10.248.169.197/{}/{}/{}/{}'
            #PASSWORD
            ).format(folders.get(f), f, y, m )
        destin = (r'D:\FSSAI-DOCS\FLRS\{}\{}\{}').format( f, y, m )
        run(gen("flrs"+f+str(y)+str(m), source, destin, exclude))

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