import os, re
BaseFolder = 'D:\FSSAI-CODE\#Revision\FLRS - Copy'
for dirs, subdirs, files in os.walk(BaseFolder):
    #patten = os.path.basename(dirs)
    for file in files:
        OfilePath = os.path.abspath(os.path.join(dirs,file))
        patten = (os.path.normpath(OfilePath).split(os.path.sep)[4])[:-2]+"??.*"
        rfile = re.sub(patten,"",file)        
        RfilePath = os.path.abspath(os.path.join(dirs,rfile))
        #print ("%s : %s" % (patten, OfilePath))
        print ("Renaming %s to %s" % (OfilePath, RfilePath))
        os.rename (OfilePath, RfilePath)
