@echo off

SET "source=D:\FSSAI-DOCS\"
SET "destni=Doc_Restore_On_%date:/=%"

for /f %%i in (list.txt) do echo F| xcopy "%source%\%%i"  "%destni%\%%i"  /i /z /y