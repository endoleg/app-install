<# See packages at 
start https://chocolatey.org/packages/
# Chocolatey Easy Installer Builder: 
start http://pmify.com/choco/
#>

# Get Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 

Write-Verbose -message "Checking if Chocolatey is already installed..." -verbose
if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
    Write-Verbose -message "Chocolatey seems to already be installed." -Verbose
}
Else
{
    Write-Verbose -message "Chocolatey not found. Installing now." -verbose
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    refreshenv
}

# config
choco feature enable -n allowEmptyChecksums
choco feature enable -n allowGlobalConfirmation

# Basic ok
choco install paint.net -y

