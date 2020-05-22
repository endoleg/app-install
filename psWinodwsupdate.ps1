Start-Transcript -Path "c:\Windows\Temp\PSWindowsUpdate.log" -Append

#Quelle: http://woshub.com/pswindowsupdate-module/

# Set TLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

write-verbose -message "NuGet install" -verbose
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

write-verbose -message "Modul install" -verbose
#Install-Module -Name PSWindowsUpdate -force
If(-not(Get-InstalledModule PSWindowsUpdate -ErrorAction silentlycontinue)){
    Install-Module -Name PSWindowsUpdate -Confirm:$False -force
}

write-verbose -message "list commands" -verbose
get-command -module PsWindowsUpdate

write-verbose -message "test only" -verbose
Get-WUHistory

Stop-transcript
