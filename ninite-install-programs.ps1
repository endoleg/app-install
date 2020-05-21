# Install Programs with Ninite
Write-Host "Installing Programs..."
New-Item C:\Task\ -type directory 2>&1 | Out-Null
$url = "https://ninite.com/.net4.7-air-chrome-foobar-inkscape-irfanview-java8-klitecodecs-libreoffice-notepadplusplus-paint.net-peazip-qbittorrent-shockwave-silverlight-spotify-steam-vscode/ninite.exe"
$output = "C:\Task\Ninite.exe"
Invoke-WebRequest $url -OutFile $output
Start-Process -FilePath "C:\Task\Ninite.exe" -Wait -Verb runas 2>&1 | Out-Null

#Invoke-WebRequest -Uri https://ninite.com/chrome/ninite.exe -OutFile ninite.exe
