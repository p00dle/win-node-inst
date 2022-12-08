$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"

. .\lib\utils.ps1
. .\lib\app-ver.ps1
. .\lib\node.ps1
. .\lib\git.ps1
. .\lib\update.ps1

makeStandaloneAppDataDir $standalone
$nodePath = getNode $standalone
$gitPath = getGit $standalone
$env:PATH += ";$(Split-Path -Path $gitPath);$(Split_path -Path $nodePath)"
$appOldVersion = getAppVersion "./app/package.json"
updateFromGithub $gitPath $appOldVersion
$appNewVersion = getAppVersion "./app/package.json"
if ($appNewVersion -ne $appOldVersion) {
  updateDependencies
  buildFromTypescript $useTsc
  refreshStartFile $appName $appNewVersion $nodePath $appEntryPoint
}

log "App fully updated to v$($appNewVersion)"
log "Run start.bat to start the app"
Read-Host -Prompt "SUCCESS: Press ENTER to exit"

