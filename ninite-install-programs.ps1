# Install Programs with Ninite
#Invoke-WebRequest -Uri https://ninite.com/chrome/ninite.exe -OutFile ninite.exe

Write-Host "Installing Programs..."
New-Item C:\Task\ -type directory 2>&1 | Out-Null
$url = "https://ninite.com/.net4.7-air-chrome-foobar-inkscape-irfanview-java8-klitecodecs-libreoffice-notepadplusplus-paint.net-peazip-qbittorrent-shockwave-silverlight-spotify-steam-vscode/ninite.exe"
$output = "C:\Task\Ninite.exe"
Invoke-WebRequest $url -OutFile $output
Start-Process -FilePath "C:\Task\Ninite.exe" -Wait -Verb runas 2>&1 | Out-Null


# Create A Scheduled Task
Write-Host "Creating A Scheduled Task..."
$taskname = "Ninite"
$descreption = "Update your Apps!"
$action = New-ScheduledTaskAction -Execute "C:\Task\Ninite.exe"
$trigger =  New-ScheduledTaskTrigger -Weekly -WeeksInterval 2 -DaysOfWeek Sunday -At 1pm
Register-ScheduledTask -TaskName $taskname -Action $action -Trigger $trigger -Description $descreption 2>&1 | Out-Null
