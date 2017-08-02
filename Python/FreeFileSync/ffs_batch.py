"""Generate and Run FreeFileSync Batch 
"""
import string
import subprocess
import os

def gen(filename, source, destin,
        exclude='', logpath=r'D:\Scripts\Temp\synclog'):
    """Genarated a .fss_batch file
    """
    #templ = open( 'fss_batch.tmpl' ).read() # Incase reading from template
    templ = """<?xml version="1.0" encoding="UTF-8"?>
<FreeFileSync XmlFormat="7" XmlType="BATCH">
    <MainConfig>
        <Comparison>
            <Variant>Size</Variant>
            <Symlinks>Exclude</Symlinks>
            <IgnoreTimeShift/>
        </Comparison>
        <SyncConfig>
            <Variant>Update</Variant>
            <CustomDirections>
                <LeftOnly>right</LeftOnly>
                <RightOnly>left</RightOnly>
                <LeftNewer>right</LeftNewer>
                <RightNewer>left</RightNewer>
                <Different>none</Different>
                <Conflict>none</Conflict>
            </CustomDirections>
            <DetectMovedFiles>false</DetectMovedFiles>
            <DeletionPolicy>RecycleBin</DeletionPolicy>
            <VersioningFolder Style="Replace"/>
        </SyncConfig>
        <GlobalFilter>
            <Include>
                <Item>*</Item>
                <Item/>
            </Include>
            <Exclude>
                <Item>\System Volume Information\</Item>
                <Item>\RECYCLER\</Item>
                <Item>\RECYCLED\</Item>
                <Item>*\desktop.ini</Item>
                <Item>*\thumbs.db</Item>
				$exclude
                <Item/>
            </Exclude>
            <TimeSpan Type="None">0</TimeSpan>
            <SizeMin Unit="None">0</SizeMin>
            <SizeMax Unit="None">0</SizeMax>
        </GlobalFilter>
        <FolderPairs>
            <Pair>
                <Left>$source</Left>
                <Right>$destin</Right>
            </Pair>
        </FolderPairs>
        <OnCompletion>Close progress dialog</OnCompletion>
    </MainConfig>
    <BatchConfig>
        <HandleError>Ignore</HandleError>
        <RunMinimized>false</RunMinimized>
        <LogfileFolder Limit="-1">$logpath</LogfileFolder>
    </BatchConfig>
</FreeFileSync>"""
    src = string.Template(templ)
    d={ 'source'  : source,  'destin'  : destin,
        'exclude' : exclude, 'logpath' : logpath }
    result = src.substitute(d)
    with open( filename+".ffs_batch", 'w') as ffsbatch:
        ffsbatch.write(result)
    return (filename+".ffs_batch")




def run(batch_file, tryn=3, clean=True, wait=True,
        exe_loc=r'C:\Program Files\FreeFileSync\FreeFileSync.exe'):
    """Runs specified FreeFileSync batch_file is run 3 times
    and removes batch file after running it by default .
    """
    ret, attempt = 1, 1
    while not ret == 0 and attempt <= tryn:
        ret = subprocess.call([exe_loc, batch_file])
        attempt += 1

    if ret == 0:
        print "=>> Done"
    elif ret == 1:
        print "=>> Done with Warnings!",
        if wait: raw_input("\t Continue..?\n")
    elif ret == 2:
        print "=>> Done with Errors!!",
        if wait: raw_input("\t Continue..?\n")
    elif ret == 3:
        print "=>> Aborted!!!      ",
        if wait: raw_input("\t Continue..?\n")

    if clean: os.remove(batch_file)
