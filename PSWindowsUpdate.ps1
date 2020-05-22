Start-Transcript -Path "c:\Windows\Temp\PSWindowsUpdate.log" -Append

#Quelle: http://woshub.com/pswindowsupdate-module/

# Set TLS to 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Turn on updates for other Microsoft products
(New-Object -ComObject Microsoft.Update.ServiceManager).AddService2("7971f918-a847-4430-9279-4a52d1efe18d", 7, "")

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

write-verbose -message "Nach Updates suchen" -verbose
Get-WindowsUpdate 

write-verbose -message "Alle Updates installieren" -verbose
Get-WindowsUpdate -AcceptAll -Install -MicrosoftUpdate -IgnoreReboot

write-verbose -message "nur zum testen - Überblick" -verbose
Get-WUHistory

Stop-transcript
