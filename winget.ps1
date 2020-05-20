
Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/tag/v0.1.4331-preview -OutFile "${Env:TEMP}\v0.1.4331-preview"
#start ${Env:TEMP}
#install it

winget install SSMS
winget install obs
winget install powertoys
winget install VLC
winget install treesize
winget install greenshot
winget install Notepad++
winget install Keepass
winget install "Advanced Installer"
winget install dropbox
winget install "Visual Studio Code"
winget install Screentogif
