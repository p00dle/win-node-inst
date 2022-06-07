function getGitPath() {
  $gitPath = where.exe /Q "git.exe"
  if ($null -ne $gitPath) {
    return $gitPath
  }
  $gitPath = "$($env:APPDATA)\win-node-inst\git\bin\git.exe"
  if (Test-Path $gitPath) {
    return $gitPath
  }
  $gitPath = "C:\Program Files\Git\bin\git.exe"
  if (Test-Path $gitPath) {
    return $gitPath
  }
  $gitPath = "C:\Program Files (x86)\Git\bin\git.exe"
  if (Test-Path $gitPath) {
    return $gitPath
  }
  return $null
}
function getGitDownloadUrl($standalone) {
  $arch = ("32", "64")[[Environment]::Is64BitOperatingSystem]
  if ($standalone) {
    $html = Invoke-WebRequest -Uri "https://git-scm.com/download/win"
    $regex = "https://github.com/git-for-windows/git/releases/download/v\d+\.\d+\.\d+\.windows\.1/PortableGit-\d+\.\d+\.\d+-$($arch)-bit.7z.exe"
    $match = Select-String -InputObject $html -Pattern $regex
    return $match.Matches[0].Value
  }
  else {
    $html = Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest"
    $regex = "/git-for-windows/git/releases/download/v\d+\.\d+\.\d+\.windows\.1/Git-\d\.\d+\.\d+-$($arch)-bit.exe"
    $match = Select-String -InputObject $html -Pattern $regex
    return "https://github.com$($match.Matches[0].Value)"
  }
}

function downloadGit($url, $standalone) {
  $gitInstaller = $url -replace "https://github.com/git-for-windows/git/releases/download/v\d+\.\d+\.\d+\.windows\.1/", ""
  $filePath = "$($env:TEMP)\$($gitInstaller)"
  Invoke-WebRequest -Uri $url -OutFile $filePath
  return $filePath
}

function installGit($standalone) {
  log "Git not installed"
  log "Getting Git current version download URL..."
  $gitDownloadUrl = getGitDownloadUrl $standalone
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
    exitWithError 2 "ERROR: Unable to find Git"
  }
  log "Git installed successfully"
  if (Test-Path $gitInstallerPath) {
    Remove-Item $gitInstallerPath
  }
  return $gitPath
}

function getGit ($standalone) {
  log "Checking if Git for Windows is installed"
  $gitPath = getGitPath
  if ($null -ne $gitPath) {
    log "Git installed"
  }
  else {
    $gitPath = installGit $standalone
  }
  log ""
  return $gitPath
}