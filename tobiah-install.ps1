param([switch]$auto=$false) # Use -auto to install without prompts

# forked from https://gist.github.com/TobiahZ/b3c6a4acdb8f8a694ee3299439c492f3
# Run this script by using:
#       PowerShell.exe -ExecutionPolicy Bypass -File .\tobiah-install.ps1
# If running from Tobiah's OneDrive, the path Tobiah uses is:
#       PowerShell.exe -ExecutionPolicy Bypass -File C:\Users\TobiahZ\OneDrive\Scripts\tobiah-install.ps1
# An even easier way to start is to create a .bat file with the following line:
#       Powershell.exe -Command "& {Start-Process Powershell.exe -ArgumentList '-ExecutionPolicy Bypass -File C:\Users\TobiahZ\OneDrive\Scripts\tobiah-install.ps1 -auto' -Verb RunAs}"
# Remember to tweak the path to the location of the script on your machine! Also note this adds "-auto" to bypass prompts.

# Here is the list of chocolatey packages to install:
$TobiahsPackages = 'firefox', 'sumatrapdf.install', 'vlc', '7zip', 'steam', 'audacity', 'git', 'dotnetcore-sdk', 'nvm', 'azure-cli', 'vscode', 'microsoft-teams'
# Extras Tobiah sometimes likes: 'gimp', 'inkscape', 'blender', 'filezilla', 'python'
# For personal machines, Tobiah adds: 'discord', 'telegram', 'grammarly', 'authy-desktop'
# If you'd like to add others, find additional available packages on https://chocolatey.org/packages

# In addition to this script, will need to manually install: Unity Hub, Visual Studio Installer, Office installer

Start-Transcript -OutputDirectory $PSScriptRoot"\logs\" -Append -IncludeInvocationHeader

Write-Host "Welcome to Tobiah's install script!"
Write-Host "This installs both Chocolatey and a bunch of Chocolatey apps"

Set-ExecutionPolicy Bypass -Scope Process -Force;

Write-Host "Checking if Chocolatey is already installed..."

if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Host "Chocolatey seems to already be installed."
}
Else
{
    Write-Host "Chocolatey not found. Installing now."
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
}

Write-Host "Starting to install apps..."

if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Host "This scrpt will install the following programs:"
    ForEach ($PackageName in $TobiahsPackages)
    {
        Write-Host $PackageName
    }

    if ($auto -eq $false)
    {
        $message  = "This script will install all of the above."
        $question = 'Are you sure you want to proceed?'

        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

        $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
    }
    else
    {
        $decision = 0
    }

    if ($decision -eq 0) {
        Write-Host 'Installing...'
        ForEach ($PackageName in $TobiahsPackages)
        {
            choco install $PackageName -y
        }
    } else {
        Write-Host 'Ok, canceled install'
    } 
}
Else
{
    Write-Host "Error: Chocolatey not found. Did install fail?"
}

Write-Host "End of Tobiah's install Script"

Stop-Transcript

Read-Host "Press ENTER to continue..."
