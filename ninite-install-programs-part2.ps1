write-verbose -message "Ninite Apps" -verbose
##################################################
###### Install from list                     #####
###### A "#" in front means it won't install #####
###### comment out needed apps               #####
###### last entry has no decimal point !!    #####
##################################################
$niniteapps = @(
    # ".net4.7",
    # "7zip",
    # "chrome",
    # "cutepdf",
    # "vlc",
    # "adaware",
    # "aimp",
    # "air",
    # "audacity",
    # "avast",
    # "avg",
    # "avira",
    # "cccp",
    # "cdburnerxp"
    # "classicstart",
    # "dropbox",
    # "eclipse",
    # "emule",
    # "essentials",
    # "evernote",
    # "everything",
    # "faststone",
    # "filezilla",
    # "firefox",
    # "foobar",
    # "foxit",
    # "gimp",
    # "glary",
    # "gom",
    # "googledrive",
    # "googleearth",
    # "greenshot",
    # "handbrake",
    # "imgburn",
    # "infrarecorder",
    # "inkscape",
    # "irfanview",
    # "itunes",
    # "java8",
    # "jdk8",
    # "jdkx8",
    "keepass2"
    # "klitecodecs",
    # "launchy",
    # "libreoffice",
    # "malwarebytes",
    # "mediamonkey",
    # "mozy",
    # "musicbee",
    # "notepadplusplus",
    # "nvda",
    # "onedrive",
    # "openoffice",
    # "operaChromium",
    # "paint.net",
    # "pdfcreator"
    # "peazip",
    # "pidgin",
    # "putty",
    # "python",
    # "qbittorrent",
    # "realvnc",
    # "revo",
    # "shockwave",
    # "silverlight",
    # "skype",
    # "spotify",
    # "spybot2",
    # "steam",
    # "sugarsync",
    # "sumatrapdf",
    # "super",
    # "teamviewer14"
    # "teracopy",
    # "thunderbird",
    # "trillian",
    # "vscode",
    # "winamp",
    # "windirstat",
    # "winmerge",
    # "winrar",
    # "winscp",
    # "xnview"
)

write-verbose -message "Download ninite and install the selected apps" -verbose
Function DoNiniteInstall {
    Write-Host "Downloading Ninite ..."
    
    $ofs = '-'
    $niniteurl = "https://ninite.com/" + $niniteapps + "/ninite.exe"
    $output = "C:\Ninite.exe"
    
    Invoke-WebRequest $niniteurl -OutFile $output
    & $output

    Write-Host
    Read-Host "Press ENTER when all applications have been installed by Ninite"
}

DoNiniteInstall

write-verbose -message "End" -verbose
