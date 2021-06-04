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
choco install paint.net -y

choco install lavfilters -y
choco install webex-meetings -y
choco install nirlauncher -y
choco install vmware-workstation-player -y
choco install vmware-powercli-psmodule -y
choco install vmwarevsphereclient -y
choco install powertoys -y
choco install treesizefree -y
choco install autoit -y
choco install obs-virtualcam -y
choco install obs-studio -y
choco install brave -y
choco install handbrake -y
choco install virtualbox -y
choco install googlechrome -y
choco install firefox -y
choco install vlc -y
choco install k-litecodecpackbasic -y
choco install dotnet -y
choco install irfanview -y
choco install audacity -y
choco install greenshot -y
choco install notepadplusplus -y
choco install winmerge -y
choco install 7zip -y
choco install teamviewer8 -y
choco install filezilla -y
choco install sysinternals -y
choco install vscode -y
choco install vscode-powershell -y
choco install adobereader -y
choco install dropbox -y
choco install putty.portable -y
choco install ffmpeg -y
choco install 4k-video-to-mp3 -y
choco install mp3directcut -y
choco install jabber
choco install webex-teams
choco install packer -y

