function updateFromGithub($gitPath) {
  Set-Location './app' | Out-Null
  $appOldVersion = getAppVersion "./package.json"
  log "Check if $($appName) is already installed"
  if ($null -eq $appOldVersion) {
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
    log "App version v$($appOldVersion) installed"
    log "Checking for updates..."
    log "[GIT LOGS START]"
    
  } 
  
  & $gitPath pull origin master
  log "[GIT LOGS END]"
  log "App is up to date"
  
  log ""
  Set-Location ".." | Out-Null
  return $appOldVersion
}

function updateDependencies() {
  Set-Location './app' | Out-Null
  log "Updating dependencies... (This may take a while)"
  $npmPath = getNpmPath
  log "[NPM LOGS START]"
  & $npmPath install --only=production | Out-Null
  log "[NPM LOGS END]"
  log "Dependencies up to date"  
  Set-Location ".." | Out-Null
}

function buildFromTypescript($useTsc) {
  if (-Not $useTsc) {
    return
  }  
  Set-Location './app' | Out-Null
  log "Building from source..."
  $npxPath = getNpxPath
  & $npxPath -- yes tsc
  log "Build complete"
  Set-Location ".." | Out-Null
}

function refreshStartFile($appName, $appNewVersion, $nodePath, $appEntryPoint) {
  $startFileContent = "@echo $($appName) v$($appNewVersion)`n@`"$($nodePath)`" `"./app/$($appEntryPoint)`"`n@pause`n"
  Set-Location '..'
  Out-File -FilePath "./start.bat" -InputObject $startFileContent -Encoding "ascii"  
}