import ffs_batch
import pickle
import os

with open ('Purged.ffs_list', 'rb') as ffs_list:
    sync_list = pickle.load(ffs_list)

for folder in sorted(sync_list, reverse=True):
    #print folders
    src = ('ftp://administrator@10.248.169.197/PURGED_DOCS/{}'
            #PASSWORD
            ).format(folder) 
    dst = os.path.join(r'D:\FSSAI-DOCS', folder)

    excLude = r'<Item> \*\ </Item>' 
    print 'Syncing {:_>17}| |{:_<30}'.format(folder, dst),
    ffs_batch.run(
        ffs_batch.gen('purge',src,dst,exclude=excLude)
    )
    
      

