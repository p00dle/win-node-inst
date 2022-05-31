. .\lib\utils.ps1
. .\lib\node.ps1
. .\lib\git.ps1

$ProgressPreference = "SilentlyContinue"
$global:ProgressPreference = "SilentlyContinue"

if (-Not (Test-Path "$($env:APPDATA)\win-node-inst")) {
  & mkdir "$($env:APPDATA)\win-node-inst" | Out-Null
}
if (-Not (Test-Path "$($env:APPDATA)\win-node-inst\node")) {
  & mkdir "$($env:APPDATA)\win-node-inst\node" | Out-Null
}
if (-Not (Test-Path "$($env:APPDATA)\win-node-inst\git")) {
  & mkdir "$($env:APPDATA)\win-node-inst\git" | Out-Null
}



log "Checking if Node.JS is installed"
$nodePath = getNodePath
if ($null -ne $nodePath) {
  log "Node.JS is installed"
}
else {
  log "Node.JS not installed"
  log "Getting Node.JS current LTS version"
  $nodeVersion = getNodeLtsVersion
  log "Current Node.JS LTS version $($nodeVersion)"
  log "Downloading Node.JS installer..."
  $nodeInstallerPath = downloadNode $nodeVersion $standalone $is64
  log $nodeInstallerPath
  log "$($env:APPDATA)\win-node-inst\node"
  log "Node.JS installer downloaded"
  if ($standalone) {
    log "Extracting Node.JS..."
    Expand-Archive -Path $nodeInstallerPath -DestinationPath "$($env:APPDATA)\win-node-inst\node" -Force 
    $extractDir = (Get-ChildItem "$($env:APPDATA)\win-node-inst\node")[0].FullName
    Rename-Item $extractDir "$($env:APPDATA)\win-node-inst\node\node" | Out-Null
    log "Node.JS extracted. Verifying installation"
  }
  else {
    log "Executing Node.JS installer; waiting until installation process finishes..."
    Start-Process msiexec.exe -Wait -ArgumentList "/I $($nodeInstallerPath)"
    log "Node.JS finished installing. Verifying installation"
  }
  $nodePath = getNodePath
  if ($null -eq $nodePath) {
    ExitWithError 2 "ERROR: Unable to find Node.JS"
  }
  log "Node.JS installed successfully"
  if (Test-Path $nodeInstallerPath) {
    Remove-Item $nodeInstallerPath
  }
}

log ""

log "Checking if Git for Windows is installed"

$gitPath = getGitPath
if ($null -ne $gitPath) {
  log "Git installed"
}
else {
  log "Git not installed"
  log "Getting Git current version download URL..."
  $gitDownloadUrl = getGitDownloadUrl $standalone $is64
  log "Downloading Git installer..."
  $gitInstallerPath = downloadGit $gitDownloadUrl
  log "Git installer downloaded"
  if ($standalone) {
    log "Extracting Git..."
    & $gitInstallerPath -o "$($env:APPDATA)\win-node-inst\git" -y | Out-Null
    log "Git extracted. Verifying installation"
  }
  else {
    log "Executing Git installer; waiting until installation process finishes..."
    Start-Process $gitInstallerPath -Wait 
    log "Git finished installing. Verifying installation"
  }
  $gitPath = getGitPath
  if ($null -eq $gitPath) {
    ExitWithError 2 "ERROR: Unable to find Git"
  }
  log "Git installed successfully"
  if (Test-Path $gitInstallerPath) {
    Remove-Item $gitInstallerPath
  }
}

log ""

log "Check if $($appName) is already installed"
if (-Not (Test-Path "./app/.git")) {
  log "App not installed. installing now"
  & mkdir ./app | Out-Null
  Set-Location './app' | Out-Null
  log "[GIT LOGS START]"
  & $gitPath init | Out-Null
  if ($null -ne $gitAccessToken) {
    & $gitPath config url."https://$($gitAccessToken):x-oauth-basic@github.com/".insteadOf "https://github.com/" | Out-Null
  }
  & $gitPath remote add origin $mainGitRepository | Out-Null
}
else {
  log "App installed. Checking for updates..."
  log "[GIT LOGS START]"
  Set-Location './app'
} 

& $gitPath pull origin master
log "[GIT LOGS END]"
log "App is up to date"

log ""

log "Updating dependencies... (This may take a while)"
$npmPath = getNpmPath
log "[NPM LOGS START]"
& $npmPath install --production | Out-Null
log "[NPM LOGS END]"
log "Dependencies up to date"

Set-Location '..'

$startFileContent = "@`"$($nodePath)`" `"./app/$($appEntryPoint)`"`n@pause`n"

if (-Not (Test-Path "./start.bat") ) {
  log "Creating start.bat file"
}
else {
  log "Updating start.bat file"
}

Out-File -FilePath "./start.bat" -InputObject $startFileContent -Encoding "ascii"

log "Success"
log "Run start.bat to start the app"
Read-Host -Prompt "Press ENTER to exit"

