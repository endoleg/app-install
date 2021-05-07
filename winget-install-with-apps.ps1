# GUI: # https://wingetit.com/ or https://winstall.app/ (more recent)
# or use Sharpapp https://github.com/mirinsoft/sharpapp and go to > Navigation > packages > Install software packages 
#
# Some parts of the Script are forked from Adriano Cahete's github site https://github.com/AdrianoCahete/winget-installer/blob/master/Install.ps1
# manual download --> Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/tag/v0.1.4331-preview -OutFile "${Env:TEMP}\v0.1.4331-preview"
# or similar to this # Add-AppxPackage -Path https://github.com/microsoft/winget-cli/releases/tag/v0.1.4331-preview.appxbundle

# Download latest Winget-release from github
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
} catch {
    Write-output "`nWinget is not installed. Try to install from MS Store instead`n"
}

##################################################
###### Install from list                     #####
###### A "#" in front means it won't install #####
###### comment in the needed apps !!         #####
###### last entry has no decimal point !!    #####
##################################################
@(
# "Microsoft.dotNetFramework",
# "Microsoft.dotnet",
# "7zip.7zip",
# "Twilio.Authy",
# "PiriformSoftware.CCleaner",
# "Google.Chrome",
# "Discord.Discord",
# "Dropbox.Dropbox",
# "TimKosse.FilezillaClient",
# "Mozilla.FirefoxESR",
# "Mozilla.Firefox",
# "gimp.gimp",
# "GitHub.GitHubDesktop",
# "Greenshot.Greenshot",
# "Inkscape.Inkscape",
# "JRSoftware.InnoSetup",
# "Apple.iTunes",
# "DominikReichl.KeePass",
# "Microsoft.Edge",
# "Microsoft.EdgeBeta",
# "Microsoft.EdgeDev",
# "Microsoft.Teams",
# "GitHub.GitHubDesktop",
# "Greenshot.Greenshot",
# "Inkscape.Inkscape",
# "JRSoftware.InnoSetup",
# "Apple.iTunes",
# "DominikReichl.KeePass",
# "Microsoft.Edge",
# "Microsoft.EdgeBeta",
# "Microsoft.EdgeDev",
# "Microsoft.Teams",
# "OBSProject.OBSStudio",
# "Notepad++.Notepad++",
# "Microsoft.Powershell",
# "Microsoft.PowerToys",
# "SimonTatham.Putty",
# "Rufus.Rufus",
# "NickeManarin.ScreenToGif",
# "ShareX.ShareX",
# "Microsoft.Skype",
# "SlackTechnologies.Slack",
# "Piriform.Speccy",
# "Microsoft.VisualStudioCode",
# "Videolan.Vlc",
# "WhatsApp.WhatsApp",
# "Microsoft.WindowsAdminCenter",
# "Microsoft.WindowsTerminal",
# "WinSCP.WinSCP",
# "WiresharkFoundation.Wireshark",
# "Zoom.Zoom",
# "Microsoft.SQLServerManagementStudio",
# "JAMSoftware.TreeSize",
) | ForEach-Object { & winget install $_ }

write-verbose -message "End" -verbose


winget install Cisco.Jabber


#########

<#
winget install name
winget show name
winget search name
winget source list
winget search -?
winget install --id=Microsoft.SQLServerManagementStudio -e

#>

#####################################################################################################################

##############################################################
# Sources https://github.com/microsoft/winget-pkgs/tree/master/manifests
# First install winget (minimum 0.3) from https://github.com/microsoft/winget-cli/releases
# With 'winget show' you can get a list of all Apps
##############################################################

# short script to get the download URL of Apps

#$App="cisco.jabber"
#$App="Cisco.WebexTeams"
$App=Cisco.CiscoWebexMeetings

$Source=(winget show $App)

$regex_Download_URL_LINE = "Download.Url:.*"
#$regex_Download_URL_LINE = "Url:[\s]*https\:\/\/.*"
$regex_HTTP = "https\:\/\/.*"

#trim spaces
#$regex_HTTP = "^[\s]*(.*?)[\s]*$"
###$regex_HTTP = "^[\s]*(.*?)[\s]*https\:\/\/.*"
#$regex_HTTP = "(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})"

$FirstRegex = $Source | Select-String -Pattern $regex_Download_URL_LINE -AllMatches | ForEach-Object { $_.Matches.Value }
$FirstRegex | Select-String -Pattern $regex_HTTP -AllMatches | ForEach-Object { $_.Matches.Value }


or

#winget search webex
(winget show Cisco.CiscoWebexMeetings | where {$_ -match '\s+Download URL:'}) -replace '\s+Download URL: ',''
