# https://stealthpuppy.com/vcredist-powershell-module/
# https://docs.stealthpuppy.com/docs/vcredist/usage/
# Aaron Parker

# Set TLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$date = get-date -Format dd.MM.yyyy
Start-Transcript -Path "c:\Windows\Temp\vcredist-$date.log"

# prerequ
Install-PackageProvider -name nuget -minimumversion 2.8.5.201 -force
Install-Module -Name VcRedist -Force
Import-Module VcRedist
new-item C:\Temp\VcRedist -ItemType directory

write-host ""
write-host ""
write-host "--------------------------"
write-host "List vcredist before"
write-host "--------------------------"
Get-InstalledVcRedist -ExportAll | Select Name, Version, ProductCode

write-host ""
write-host ""
write-host "--------------------------"
write-host "Installation"
write-host "--------------------------"
$VcList = Get-VcList
Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Install-VcRedist -Path C:\Temp\VcRedist -VcList (Get-VcList) -Silent

write-host ""
write-host ""
write-host "--------------------------"
write-host "List vcredist before"
write-host "--------------------------"
Get-InstalledVcRedist -ExportAll | Select Name, Version, ProductCode

stop-transcript
