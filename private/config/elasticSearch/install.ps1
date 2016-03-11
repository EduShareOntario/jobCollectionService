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

$newIndexName = 'easysearch_v1'
$aliasIndexName = 'easysearch'
$thisScriptPath = $($MyInvocation.MyCommand.Path)
$rootPath = Split-Path $thisScriptPath -parent
$serviceRootUrl = 'http://localhost:9200'
$newIndexUrl = "$($serviceRootUrl)/$($newIndexName)"
$aliasIndexUrl = "$($serviceRootUrl)/$($aliasIndexName)"
$indexMappingUrl = "$($serviceRootUrl)/$($newIndexName)/_mapping"
$aliasesUrl = "$($serviceRootUrl)/_aliases"
$indexConfigFilename = "$($rootPath)\indexConfig.json"
$transcriptMappingFilename = "$($rootPath)\transcriptMapping.json"
$aliasesConfigFilename = "$($rootPath)\aliasesConfig.json"

Push-Location $rootPath
try {
	Write-Host "Making sure $($newIndexName) isn't the current index for $($aliasIndexUrl)"
	invoke-webrequest -verbose -method HEAD $newIndexUrl
	invoke-webrequest -verbose -debug -method HEAD "$($newIndexUrl)/_alias/$($aliasIndexName)"
	Write-Host "Ooops.  Not expecting the new index $($newIndexName) to have the current alias $($aliasIndexName)"
	Write-Host "The new index MUST NOT be the current index in use via the alias index url $($aliasIndexUrl)"
    exit 44444
} catch {
	try {
		Write-Host "Attempting to delete $($newIndexName)"
		invoke-webrequest -verbose -debug -method delete -Uri $newIndexUrl -ErrorAction "Ignore"
	} catch {
		Write-Host "Non-fatal Error: Failed to delete existing index"
		Write-Host $_
	}
}
Write-Host "Creating new index $($newIndexName)"
invoke-webrequest -verbose -debug -method post -Uri $newIndexUrl -InFile $indexConfigFilename

Write-Host "Creating custom mapping for transcript documents"
invoke-webrequest -verbose -debug -method post -Uri "$($indexMappingUrl)/transcript" -InFile $transcriptMappingFilename

Write-Host "Indexing Transcript documents from current index $($aliasIndexUrl) to new index $($newIndexUrl)"
node .\node_modules\elasticsearch-reindex\bin\elasticsearch-reindex.js -f $aliasIndexUrl/transcript -t $newIndexUrl/transcript

Write-Host "Switching index alias $($aliasIndexName) to new index $($newIndexName)"
$swapAliasJSON =
@"
	{
		"actions":
		[
			{ "remove": { "index": "*", "alias": "$($aliasIndexName)" } },
			{ "add": { "index": "$($newIndexName)", "alias": "$($aliasIndexName)" } }
		]
	}
"@
invoke-RestMethod -verbose -debug -method post -Uri $aliasesUrl -Body $swapAliasJSON

Pop-Location