Remove-Item -Path $env:temp\* -Force -Recurse
Remove-Item -Path $env:appdata\Microsoft\Windows\"Start Menu"\Programs\startup\* -Force -Recurse
Remove-LocalUser -Name "onlyrat"
