write-verbose -message "Removing C:\Windows\Temp\sharpapp.exe and C:\Windows\Temp\sharpapp\*" -verbose
remove-item "C:\Windows\Temp\sharpapp.*" -force -ErrorAction SilentlyContinue
remove-item "C:\Windows\Temp\scripts\*" -Recurse -Force -ErrorAction SilentlyContinue

write-verbose -message "Download latest sharpapp release from github - https://github.com/mirinsoft/sharpapp" -verbose
$Repo = "https://api.github.com/repos/mirinsoft/sharpapp/releases/latest"

write-verbose -message "Query the API to get the url of the zip" -verbose
$APIResponse = Invoke-RestMethod -Method Get -Uri $Repo
$APIResponse
$FileUrl = $APIResponse.assets.browser_download_url
$FileUrl

$downloadFile = "C:\Windows\Temp\sharpapp.zip"

write-verbose -message "Download" -verbose
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile(“$FileUrl” ,
                        $downloadFile)
Write-Output “Downloaded to $downloadFile”

Write-Output “extract”
Expand-Archive $downloadFile -DestinationPath C:\Windows\Temp\ -Force

write-verbose -message "starting sharpapp" -verbose
cd C:\Windows\Temp\
Start-Process C:\Windows\Temp\sharpapp.exe

<#
START http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/endoleg/app-install/master/Optimizations.ps1
#>
