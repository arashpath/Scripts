@echo off
set out="0KBFiles.txt"
set source="F:\FSSAI-DOCS1\FLRS\REG\2017\7"
(for /r %source% %%F in (*.*) do (if %%~zF LSS 1 echo %%F)) > %out%
pause