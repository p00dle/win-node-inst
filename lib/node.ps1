function getNodeLtsVersion() {
  $url = "https://nodejs.org/download/release/index.json"
  $response = Invoke-WebRequest -URI $url
  
  $json = ConvertFrom-Json -InputObject $response
  $ltsObject = $json | Where-Object { $_.lts }
  return $ltsObject[0].version
}
function downloadNode($version, $standalone) {
  $arch = ("x86", "x64")[[Environment]::Is64BitOperatingSystem]
  $nodeInstaller = ""
  if ($standalone) {
    $nodeInstaller = "node-$($version)-win-$($arch).zip"
  }
  else {
    $nodeInstaller = "node-$($version)-$($arch).msi"
  }
  $nodeInstallerPath = "$($env:TEMP)\$($nodeInstaller)"
  $url = "https://nodejs.org/dist/$($version)/$($nodeInstaller)"
  Invoke-WebRequest -Uri $url -OutFile $nodeInstallerPath -UseBasicParsing
  return $nodeInstallerPath
}

function getNodePath() {
  $nodePath = "$($env:APPDATA)\win-node-inst\node\node\node.exe"
  if (Test-Path $nodePath) {
    return $nodePath
  }
  $nodePath = "C:\Program Files\nodejs\node.exe"
  if (Test-Path $nodePath) {
    return $nodePath
  }
  $nodePath = "C:\Program Files (x86)\nodejs\node.exe"
  if (Test-Path $nodePath) {
    return $nodePath
  }
  return $null
}

function getNpmPath() {
  $npmPath = "$($env:APPDATA)\win-node-inst\node\node\npm.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  $npmPath = "C:\Program Files\nodejs\npm.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  $npmPath = "C:\Program Files (x86)\nodejs\npm.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  return $null
}

function getNpxPath() {
  $npmPath = "$($env:APPDATA)\win-node-inst\node\node\npx.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  $npmPath = "C:\Program Files\nodejs\npx.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  $npmPath = "C:\Program Files (x86)\nodejs\npx.cmd"
  if (Test-Path $npmPath) {
    return $npmPath
  }
  return $null
}

function installNode($standalone) {
  log "Node.JS not installed"
  log "Getting Node.JS current LTS version"
  $nodeVersion = getNodeLtsVersion
  log "Current Node.JS LTS version $($nodeVersion)"
  log "Downloading Node.JS installer..."
  $nodeInstallerPath = downloadNode $nodeVersion $standalone
  log "Node.JS installer downloaded"
  if ($standalone) {
    log "Extracting Node.JS..."
    Expand-Archive -Path $nodeInstallerPath -DestinationPath "$($env:APPDATA)\win-node-inst\node" -Force 
    $extractDir = (Get-ChildItem "$($env:APPDATA)\win-node-inst\node")[0].FullName
    Start-Sleep 5
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
    exitWithError 2 "ERROR: Unable to find Node.JS"
  }
  log "Node.JS installed successfully"
  if (Test-Path $nodeInstallerPath) {
    Remove-Item $nodeInstallerPath
  }
  return $nodePath
}

function getNode($standalone) {
  log "Checking if Node.JS is installed"
  $nodePath = getNodePath
  if ($null -ne $nodePath) {
    log "Node.JS is installed"
  }
  else {
    $nodePath = (installNode $standalone)
  }
  log ""
  return $nodePath

}