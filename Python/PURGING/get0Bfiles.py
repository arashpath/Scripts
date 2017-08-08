#!/bin/env python
import sys
import os
import progressbar

if len(sys.argv) < 2:
    sys.exit('Usage getZeroKBfiles.exe "full:/path/of/folder/to/scan"')  
else:
    scan_folder = os.path.normpath(sys.argv[1])

print 'Scanning '+scan_folder
with open('ZeroBite.log', 'w') as zlog:
    pbar = progressbar.ProgressBar()       
    for contents in pbar(os.listdir(scan_folder)):
        scan_file = os.path.join(scan_folder, contents)
        if os.path.isfile(scan_file) and os.path.getsize(scan_file) == 0:
            print >>zlog, scan_file
            os.renames(scan_file, os.path.join(os.getcwd(), 'ZeroBite', contents))