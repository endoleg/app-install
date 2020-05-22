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

######### Basic test begin
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

<#
 #Logs
 start "C:\ProgramData\chocolatey\logs\chocolatey.log"
 
 #Powershell-Sources 
 start "C:\ProgramData\chocolatey\lib\"
#>
