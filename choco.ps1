# See packages at https://chocolatey.org/packages/

# Get Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#pre
choco feature enable -n allowEmptyChecksums
choco feature enable -n allowGlobalConfirmation

# Basic
choco install googlechrome -y
choco install firefox -y

choco install vlc -y
choco install irfanview -y
choco install audacity -y
choco install paint.net -y
choco install greenshot -y
choco install openoffice -y
choco install notepadplusplus -y
choco install winmerge -y
choco install 7zip -y
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

#choco install handbrake -y
#choco install brave -y
#choco install obs -y
#choco install autoit -y
#choco install powertoys -y
#choco install treesize -y
#choco install pdfxchange -y

# choco install powershell-core -y
# Microsoft .NET Framework 4.7.2
# choco install netfx-4.7.1-devpack -y
# or Microsoft .NET Framework 4.7.2
# choco install dotnetfx -y
# or Microsoft .NET Framework 4.7.2 Developer Pack
# choco install netfx-4.7.2-devpack
# Microsoft .NET Core 2.2.6
# choco install dotnetcore -y
# or Microsoft .NET Core Runtime (Install) 2.2.6
# choco install dotnetcore-runtime.install -y
# More Dev
# choco install sql-server-management-studio -y

#Chocolatey Easy Installer Builder
#http://pmify.com/choco/