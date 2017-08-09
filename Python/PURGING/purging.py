#!/usr/env python
from win32com.client import GetObject

KB = float(1024)
MB = float(KB ** 2) # 1,048,576
GB = float(KB ** 3) # 1,073,741,824
TB = float(KB ** 4) # 1,099,511,627,776

def hb(B):
   'Return the given bytes as a human friendly KB, MB, GB, or TB string'
   B  = float(B)

   if B < KB:
      return '{0} {1}'.format(B,'Bytes' if 0 == B > 1 else 'Byte')
   elif KB <= B < MB:
      return '{0:.2f} KB'.format(B/KB)
   elif MB <= B < GB:
      return '{0:.2f} MB'.format(B/MB)
   elif GB <= B < TB:
      return '{0:.2f} GB'.format(B/GB)
   elif TB <= B:
      return '{0:.2f} TB'.format(B/TB)

def fs(drive=''):
   'Return Free Space of a given drive letter'
   try:
       free_space = GetObject(
          "winmgmts:root\cimv2:Win32_LogicalDisk='"+drive+":'"
          ).FreeSpace
       return float(free_space)
   except:
        return None
 
def fs_check(required_space,drive,con=GB):
   if required_space*con >= fs(drive):
      return False
   else:
      return True

