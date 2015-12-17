Write-Output "This File Path: $($MyInvocation.MyCommand.Path)"
$rootPath = Split-Path $MyInvocation.MyCommand.Path -parent
cd $rootPath
Write-Output "Current Path: $(Get-Location)"
Remove-Item -path jobCollectionService.tar
& '7z' x jobCollectionService.tar.gz
Write-Output "Ensure the Node processes are stopped"
Pause
$env:Path = "c:\Program Files (x86)\nodejs;$($env:Path)"
#Remove-Item : The specified path, file name, or both are too long. The fully qualified file name must be less than 260
#The following is a hack to avoid the above error when using "Remove-Item -path bundle -recurse -force"
& 'cmd' /C "rd bundle /q /s"
Remove-Item -path PaxHeader -recurse -force
Pause
Write-Output "Extracting Archive"
& '7z' x jobCollectionService.tar
Write-Output "Removing bcyrpt from extract location"
Remove-Item -path bundle\programs\server\npm\npm-bcrypt -recurse -force
Write-Output "Installing bcrypt"
& 'npm' install bcrypt --msvs_version=2012
Write-Output "Installing application via NPM"
cd bundle\programs\server
& 'npm' install --msvs_version=2012
Write-Output "Start the IIS Application/pool 'transcript'"
cd $rootPath