# Configures ElasticSearch index at http://localhost:9200
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

$indexName = 'easysearch_v1'
$thisScriptPath = $($MyInvocation.MyCommand.Path)
$rootPath = Split-Path $thisScriptPath -parent
$serviceRootUrl = 'http://localhost:9200'
$createIndexUrl = "$($serviceRootUrl)/$($indexName)"
$indexMappingUrl = "$($serviceRootUrl)/$($indexName)/_mapping"
$aliasesUrl = "$($serviceRootUrl)/_aliases"
$indexConfigFilename = "$($rootPath)\indexConfig.json"
$transcriptMappingFilename = "$($rootPath)\transcriptMapping.json"
$aliasesConfigFilename = "$($rootPath)\aliasesConfig.json"

Push-Location $rootPath
try {
    invoke-webrequest -method delete -Uri $createIndexUrl -ErrorAction "Ignore"
} catch {
    Write-Host "Failed to delete existing index"
    Write-Host $_
}
invoke-webrequest -method post -Uri $createIndexUrl -InFile $indexConfigFilename
invoke-webrequest -method post -Uri "$($indexMappingUrl)/transcript" -InFile $transcriptMappingFilename
# Add additional index type mappings
# invoke-webrequest -method post -Uri "$($indexMappingUrl)/abc" -InFile $abcMappingFilename
#
invoke-webrequest -method post -Uri $aliasesUrl -InFile $aliasesConfigFilename
Pop-Location