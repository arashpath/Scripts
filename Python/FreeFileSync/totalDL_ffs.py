import glob
conv = {'KB' : 1024,
        'MB' : 1024**2,
        'GB' : 1024**3,
        'TB' : 1024**4 }

def byteme(size):
    return (float(size[:-3])*conv[size[-2:]] )
def hb(size):
    if   size >=  conv['TB']:
        return ('{:.2f} TB'.format(size/conv['TB']))
    elif size >=  conv['GB']:
        return ('{:.2f} GB'.format(size/conv['GB']))
    elif size >=  conv['MB']:
        return ('{:.2f} MB'.format(size/conv['MB']))
    elif size >=  conv['KB']:
        return ('{:.2f} KB'.format(size/conv['KB']))

total_files = 0
total_size  = 0

for logfile in glob.glob(r'D:\Scripts\Temp\synclog\purge 2017-08-17*.log' ):
    with open (logfile, 'r') as l:
        for line in l.readlines():
            if 'Items processed: ' in line:
                if not line[22:23] == '0':
                    count, size  = line[22:].strip().split('(')
                    total_files += int(count)
                    total_size  += byteme(size[:-1])        
print '{} {}'.format(total_files,hb(total_size))