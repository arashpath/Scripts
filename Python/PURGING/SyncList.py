import os
import pickle

base_folder = 'G:\PURGED_DOCS'

folder_list = [] 
for folder, sub_folders, files in os.walk(base_folder):
    folder_list += [os.path.relpath(folder, base_folder)]
folder_list.pop(0)

try:
    with open('Purged.ffs_list', 'wb') as f_list:
        pickle.dump(folder_list, f_list)
except IOError as ioerr:
    print 'FileError: '+str(ioerr)
except pickle.PickleError as perr:
    print 'PickleError: '+str(perr)