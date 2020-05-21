
#Invoke-WebRequest https://github.com/microsoft/winget-cli/releases/tag/v0.1.4331-preview -OutFile "${Env:TEMP}\v0.1.4331-preview"
#start ${Env:TEMP}
#install it

# =============================================================
# Copyright 2020 Adriano Cahete <https://adrianocahete.dev/>
# TODO: Add License
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =============================================================

# Install Winget
# TODO: Check windows version
# TODO: Check if it's easier to get from repository or MS Store
# TODO: Check if Sideloading is enabled - https://docs.microsoft.com/en-us/windows/uwp/get-started/enable-your-device-for-development
# TODO: Do the option to enable sideloading from PS console (I don't know even it's possible)
# TODO: Clear old files before start


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
