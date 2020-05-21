
#Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/tag/v0.1.4331-preview -OutFile "${Env:TEMP}\v0.1.4331-preview"
#start ${Env:TEMP}

# from Adriano Cahete's github site https://github.com/AdrianoCahete/winget-installer/blob/master/Install.ps1
# <https://adrianocahete.dev/>

# Install Winget

# Download latest release from github
$Repo = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

# --- Query the API to get the url of the zip
$APIResponse = Invoke-RestMethod -Method Get -Uri $Repo
$FileUrl = $APIResponse.assets.browser_download_url

# --- Download the file to the current location
$fileName = "$($APIResponse.name.Replace(" ","_")).appxbundle"
$OutputPath = "$((Get-Location).Path)\files\$fileName"

if (Test-Path -Path "$((Get-Location).Path)\files\")  {
    Push-Location files
    Write-Output "Downloading $fileName ...`n"
    Invoke-RestMethod -Method Get -Uri $FileUrl -OutFile $OutputPath
} else {
    mkdir files > $null
    Push-Location files
    Write-Output "Downloading $fileName ... `n"
    Invoke-RestMethod -Method Get -Uri $FileUrl -OutFile $OutputPath
}

Write-Output "`nInstalling $fileName ...`n"
Add-AppxPackage $OutputPath
Pop-Location
refreshenv

try {
   Write-Output "Winget version is: " 
   winget --version
   Write-Output "`nWinget is installed. Try to run the 'winget' command.`n" 
} catch {
    Write-output "`nWinget is not installed. Try to install from MS Store instead`n"
}

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

winget show
