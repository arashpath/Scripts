SET "source=D:\FSSAI-DOCS\"
SET "destni=DOC_Restore"

for /f %%i in (list.txt) do echo F| xcopy "%source%\%%i"  "%destni%\%%i"  /i /z /y