# https://github.com/mirinsoft/sharpapp

# Download latest release from github
$Repo = "https://api.github.com/repos/mirinsoft/sharpapp/releases/latest"

# --- Query the API to get the url of the zip
$APIResponse = Invoke-RestMethod -Method Get -Uri $Repo
$APIResponse
$FileUrl = $APIResponse.assets.browser_download_url
$FileUrl

$downloadFile = "C:\Windows\Temp\sharpapp.zip"

# Let the download begin!
Write-Output “Starting download”
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile(“$FileUrl” ,
                        $downloadFile)
Write-Output “Downloaded to $downloadFile”

Write-Output “extract”
Expand-Archive $downloadFile -DestinationPath C:\Windows\Temp\ -Force

#start C:\Windows\Temp\
Get-Process sharpapp -ErrorAction SilentlyContinue

start C:\Windows\Temp\sharpapp.exe
