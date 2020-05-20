Set-ExecutionPolicy Bypass -Scope Process -Force; 
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

Invoke-WebRequest https://beeftext.org/translations/BeeftextDe.zip -OutFile "${Env:TEMP}\BeeftextDe.zip"
Expand-Archive -LiteralPath "${Env:TEMP}\BeeftextDe.zip" -DestinationPath "${LOCALAPPDATA}\\beeftext.org\Beeftext\Translations"

# ChocoInstallBase.ps1 by atwork.at
# Get Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# See packages at https://chocolatey.org/packages/
# Use according to your own needs...

choco feature enable -n allowEmptyChecksums
choco feature enable -n allowGlobalConfirmation

choco install keepass -y
choco install audacity -y

# Essentials
choco install notepadplusplus -y
choco install googlechrome -y
choco install firefox -y
choco install adobereader -y
choco install vlc -y
# Msft & Office
choco install skype -y
choco install powerbi -y
# Additional Tools
choco install 7zip -y
choco install irfanview -y
choco install greenshot -y
choco install filezilla -y
choco install curl -y
choco install youtube-dl -y
choco install expressvpn -y
# Azure
choco install azure-cli -y
choco install azcopy -y
# More Tools
choco install powershell-core -y
choco install sysinternals -y
choco install rdcman -y
# Dev
choco install git -y
choco install vscode -y
choco install vscode-powershell -y
choco install postman -y
choco install fiddler -y
# Microsoft .NET Framework 4.7.2
choco install netfx-4.7.1-devpack -y
# or Microsoft .NET Framework 4.7.2
choco install dotnetfx -y
# or Microsoft .NET Framework 4.7.2 Developer Pack
choco install netfx-4.7.2-devpack
# Microsoft .NET Core 2.2.6
choco install dotnetcore -y
# or Microsoft .NET Core Runtime (Install) 2.2.6
choco install dotnetcore-runtime.install -y
# More Dev
choco install sql-server-management-studio -y


START http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/endoleg/snippets/master/boxstarter-install-choco-programs

#Chocolatey Easy Installer Builder
#http://pmify.com/choco/