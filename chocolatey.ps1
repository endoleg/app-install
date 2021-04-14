<# See packages at 
start https://chocolatey.org/packages/
# Chocolatey Easy Installer Builder: 
start http://pmify.com/choco/
#>

# Get Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 

Write-Verbose -message "Checking if Chocolatey is already installed..." -verbose
if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Verbose -message "Chocolatey seems to already be installed." -Verbose
}
Else
{
    Write-Verbose -message "Chocolatey not found. Installing now." -verbose
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
}

# config
choco feature enable -n allowEmptyChecksums
choco feature enable -n allowGlobalConfirmation

# Basic ok
choco install whatsapp -y
choco install windows-admin-center -y
choco install lavfilters -y
choco install webex-meetings -y
choco install nirlauncher -y
choco install innosetup -y
choco install wireshark -y
choco install vmware-tools -y
choco install vmware-workstation-player -y
choco install vmware-powercli-psmodule -y
choco install vmwarevsphereclient -y
choco install vmrc -y
choco install powertoys -y
choco install treesizefree -y
choco install masterpackager -y
choco install autohotkey -y
choco install autoit -y
choco install obs-virtualcam -y
choco install obs-studio -y
choco install brave -y
choco install handbrake -y
choco install virtualbox -y
choco install inkscape -y
choco install googlechrome -y
choco install firefox -y
choco install xnview -y
choco install openoffice -y
choco install googledrive -y 
choco install keepass -y
choco install launchy -y
choco install vlc -y
choco install k-litecodecpackbasic -y
choco install flashplayerplugin -y
choco install dotnet -y
choco install irfanview -y
choco install audacity -y
choco install paint.net -y
choco install greenshot -y
choco install openoffice -y
choco install notepadplusplus -y
choco install winmerge -y
choco install 7zip -y
choco install teamviewer6 -y
choco install teamviewer -y
choco install filezilla -y
choco install sysinternals -y
choco install vscode -y
choco install vscode-powershell -y
choco install adobereader -y
choco install skype -y
choco install keepass -y
choco install gimp -y
choco install dropbox -y
choco install putty.portable -y
choco install ffmpeg -y
choco install 4k-video-to-mp3 -y
choco install mp3directcut -y
choco install jabber
choco install webex-teams
choco install webex-meetings

# choco install pdfxchange -y

# choco install powershell-core -y

# Microsoft .NET Framework latest (4.8)
# choco install dotnetfx -y

# or Microsoft .NET Framework 4.7.2 Developer Pack
# choco install netfx-4.7.2-devpack

# Microsoft .NET Core 2.2.6
# choco install dotnetcore -y

# or Microsoft .NET Core Runtime (Install) 2.2.6
# choco install dotnetcore-runtime.install -y

# More Dev
# choco install sql-server-management-studio -y
######### Basic test end

Write-verbose -message "Creating Daily Task To Automatically Upgrade Chocolatey Packages" -verbose
$Taskname = "ChocolateyDailyUpgrade"
$Taskaction = New-Scheduledtaskaction -Execute C:\Programdata\Chocolatey\Choco.Exe -Argument "Upgrade All -Y"
$Tasktrigger = New-Scheduledtasktrigger -At 2am -Daily
# Note about TaskUser, I noticed that you have to put the account name. 
# If domain account, don't include the domain. int.domain.com\bob.domain would just be bob.domain
$Taskuser = "ReplaceMe"
Register-Scheduledtask -Taskname $Taskname -Action $Taskaction -Trigger $Tasktrigger -User $Taskuser

# Cisco Jabber - https://community.chocolatey.org/packages/jabber 
$ErrorActionPreference = 'Stop';
$url            = 'https://binaries.webex.com/static-content-pipeline/jabber-upgrade/production/jabberdesktop/apps/windows/public/14.0.0.305563/CiscoJabberSetup.msi'
$packageArgs = @{
  packageName   = $env:ChocolateyPackageName
  fileType      = 'msi'
  url           = $url
  softwareName  = 'Cisco Jabber*'
  silentArgs    = "/qn /norestart"
  validExitCodes= @(0, 3010, 1641)
}
Install-ChocolateyPackage @packageArgs

# Cisco Webex Teams - https://community.chocolatey.org/packages/webex-teams
$ErrorActionPreference = 'Stop';
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  fileType     = 'MSI'
  url          = 'https://binaries.webex.com/WebexTeamsDesktop-Windows-Gold/WebexTeams.msi'
  silentArgs   = "/qn /norestart /l*v `"$env:TEMP\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
}
Install-ChocolateyPackage @packageArgs

# Cisco Webex Meetings - https://community.chocolatey.org/packages/webex-meetings
$ErrorActionPreference = 'Stop';
$packageArgs = @{
  packageName  = $env:ChocolateyPackageName
  fileType     = 'MSI'

  url          = 'https://akamaicdn.webex.com/client/webexapp.msi'
  silentArgs   = "/qn /norestart /l*v `"$env:TEMP\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`" AUTOOC=0"
}
Install-ChocolateyPackage @packageArgs

<#
 #Logs
 start "C:\ProgramData\chocolatey\logs\chocolatey.log"
 
 #Powershell-Sources 
 start "C:\ProgramData\chocolatey\lib\"
#>
