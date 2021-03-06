# Installs the application based on the latest master repository source.
#
# Install:
# Copy to the project root directory on the target server.
#
# Run:
# Execute as a powershell script.
# eg.
# - From File Exporer -> right click on the filename + Run with Powershell
# - From Powershell window -> . c:\apps\local\transcript\install.ps1
#
# Regardless of how it is launched it makes all it's directory references
# relative to it's location!!!
#

# Default to stopping on errors vs. the default of continue!!
# See https://technet.microsoft.com/en-us/library/hh847796.aspx for behavior
$ErrorActionPreference="Stop"

#
# Github/Project Specific Configuration
#
$githubArchiveUrl="https://github.com/EduShareOntario/jobCollectionService/archive/master.zip"
$githubArchiveRootPath="jobCollectionService-master"

#
# Install dependency configuration
#
$nodePath='c:\node\8.11.4'
$meteorPath='C:\apps\local\.meteor'
$msvs_version=2012
function isCorrectNodeVersion() {
    & node --eval "{if (process.arch == 'x64') { process.exit(99); } }"
    return ($lastexitcode -eq 99)
}

if (-Not (isCorrectNodeVersion)) {
    Write-Output "Adding default 64 Bit nodejs to beginning of path"
    $Env:path =  $nodePath + ";" + $Env:path
    if (-Not (isCorrectNodeVersion)) {
        throw "Error. invalid nodejs version!!!!"
    }
}
if (-Not (Get-Command meteor -ErrorAction "Ignore")) {
    $Env:path += ";"+$meteorPath
    Write-Output "Path is $($Env:path)"
}
($env:Path).Replace(';',"`n")

#
# Install process configuration
#
$thisScriptPath = $($MyInvocation.MyCommand.Path)
$rootPath = Split-Path $thisScriptPath -parent
$buildRoot = "$($rootPath)\build"
$currentRoot = "$($rootPath)\current"
$currentBundleRoot = "$($currentRoot)\bundle"
$logRoot = "$($rootPath)\logs"
$backupRoot = "$($rootPath)\backup"
$buildApplicationRoot = "$($buildRoot)\$($githubArchiveRootPath)"
$buildBundleRoot = "$($buildApplicationRoot)\bundle"
$buildServerApplicationRoot = "$($buildBundleRoot)\programs\server"

#
# Log Step message
#
function logStepMessage($msg) {
	$breakLine = "=============================================================="
	Write-Output $breakLine
	Write-Output $msg
}

#
# Get the latest from Github
#
function getLatestFromGithub() {
	logStepMessage "Getting latest code from Github at $($githubArchiveUrl)"
	#Hack to allow install without Github access.
    #$latestZipFilename = "$($buildRoot)\latest.zip"
    #Invoke-WebRequest $githubArchiveUrl -OutFile $latestZipFilename -Verbose
	$latestZipFilename = "$($rootPath)\latest.zip"
    Write-Output "Caution: Manually download ${$githubArchiveUrl} to $latestZipFilename before proceeding."
    Pause
    #todo: if/when powershell 5 is available
    #Expand-Archive $latestZipFilename -Force
    7z x $latestZipFilename -o"$($buildRoot)"
}

#
# Prepare latest build
#
function build() {
	logStepMessage "Cleanup filesystem from previous build"

    # Cleanup filesystem from previous build
    if (Get-Item $buildRoot -ErrorAction Ignore) {
		Write-Output "Removing old build directory $($buildRoot)"
		# Remove-Item : The specified path, file name, or both are too long. The fully qualified file name must be less than 260
        # The following is a hack to avoid the above error when using:
        #   Remove-Item -path $buildRoot -force -recurse -WarningAction "Ignore"
        & 'cmd' /C "rd $($buildRoot) /q /s"
    }
    New-Item $buildRoot -type Directory -Force

    Push-Location $buildRoot

    getLatestFromGithub

    # Build it
    logStepMessage "Building Meteor bundle"
    Set-Location $buildApplicationRoot
    & 'meteor' build $buildApplicationRoot --directory
    if ($LastExitCode -ne 0) { throw "meteor build failed" }
    logStepMessage "Replacing bcrypt package"
	Set-Location $buildServerApplicationRoot
    Remove-Item -path "npm\npm-bcrypt" -Recurse -Force -Verbose
    & 'npm' install bcrypt --msvs_version=$msvs_version
    if ($LastExitCode -ne 0) { throw "bcrypt install failed" }
    logStepMessage "Installing Node Modules in $($buildServerApplicationRoot)"
    & 'npm' install --msvs_version=$msvs_version
    if ($LastExitCode -ne 0) { throw "install failed" }

    Pop-Location
}


#
# Backup the current version
#
function backup() {
	logStepMessage "Backing up current"
    $backupFilename="$($backupRoot)\backup_$(Get-Date -Format 'yyyymmddThhmmssmsms').zip"
    Write-Output "Archiving $($currentRoot) to $($backupFilename) excluding node_modules"
    $currentNodeModules = "$($currentBundleRoot)\node_modules"
    & 7z a $backupFilename $currentRoot -x!$currentNodeModules
    # Exit code 1 is a warning!
    if ($LastExitCode -gt 1) { throw "backup failed with exit code:$($LastExitCode)" }
}

#
# Activate the latest build and start the application
#
function activateLatestBuild() {
	logStepMessage "Activating latest build"

    #todo: automate stop
    Write-Output "Stop the IIS Application Pool 'transcript' and ennsure the Node processes are stopped."
    Pause

    logStepMessage "Replacing current version"
    # Remove-Item : The specified path, file name, or both are too long. The fully qualified file name must be less than 260
    # The following is a hack to avoid the above error when using:
    #   Remove-Item -path $currentRoot -recurse -force -WarningAction "Ignore"  -ErrorAction "Ignore"
    if (Get-Item $currentBundleRoot -ErrorAction "Ignore") {
        & 'cmd' /C "rd $currentBundleRoot /q /s"
    }
	if (-Not (Get-Item $currentRoot -ErrorAction "Ignore")) {
		New-Item $currentRoot -ItemType Directory
	}
    Move-Item -path $buildBundleRoot $currentBundleRoot -force -verbose

    Write-Output "Start the IIS Application Pool 'transcript'"
    Pause
    #todo: automate start
}

#
# Mainline Install
#

try {
	logStepMessage "Running script: $($thisScriptPath)"
	Set-Location $rootPath
	Write-Output "Current Path: $(Get-Location)"
	build
	backup
	activateLatestBuild
}
catch {
    Write-Host "Exiting with code 9999"
    exit 9999
}

