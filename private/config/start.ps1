$env:MONGO_URL="mongodb://localhost:27017,localhost:27018,localhost:27019/jobs?replicaSet=rs1&readPreference=primaryPreferred&w=majority"
$env:MONGO_OPLOG_URL="mongodb://localhost:27017/local"
$env:METEOR_SETTINGS='{"jobCollections": [{"name": "student-transcript","adminUserIds": [],"adminGroups": ["GG-ADMIN-Information Technology-Enterprise Systems-Production"],"scheduledJobs": ["getInboundTranscriptRequestIdsFromOCAS","getOutboundTranscriptRequestIdsFromOCAS"]}],"public": {"jobCollections": [{"name": "student-transcript"}],"transcriptToHtmlURL": "http://apps.georgiantest.com/transformdoc"},"ldap": {"debug": true,"domain": "georgiancollege.ca","baseDn": "ou=Georgian,dc=admin,dc=georgianc,dc=on,dc=ca","url": "ldap://badcadm03.admin.georgianc.on.ca/","bindCn": "cn=0-LDAPGrails,ou=Service Accounts,ou=Georgian,dc=admin,dc=georgianc,dc=on,dc=ca","bindPassword": "Gr00vy:Tra1n","autopublishFields": ["displayName","givenName","department","employeeNumber","mail","title","address","phone"],"groupMembership": ["APP-XML-TransQueue"]}}'
$env:ROOT_URL="http://localhost:3000/transcript"
$env:PORT="3000"

$thisScriptPath = $($MyInvocation.MyCommand.Path)
$rootPath = Split-Path $thisScriptPath -parent
$currentRoot = "$($rootPath)\current"

#
# dependency configuration
#
$nodePath='c:\apps\nodejs\8.11.4'
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

Push-Location $currentRoot
& node $args bundle/main.js
Pop-Location