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
Write-Output “Starting download of the Sysinternals Suite”
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile(“$FileUrl” ,
                        $downloadFile)
Write-Output “Sysinternals suite downloaded to $downloadFile”

start C:\Windows\Temp\


try {
   Write-Output "Version is: " 
   sharpapp.exe --version
   Write-Output "`nsharapp is installed `n" 
} catch {
    Write-output "`nsharapp is not installed. Try to install from https://github.com/mirinsoft/sharpapp instead`n"
}
