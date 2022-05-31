function getNodeLtsVersion() {
  $url = "https://nodejs.org/download/release/index.json"
  $response = Invoke-WebRequest -URI $url
  
  $json = ConvertFrom-Json -InputObject $response
  $ltsObject = $json | Where-Object { $_.lts }
  return $ltsObject[0].version
}
function downloadNode($version, $standalone, $is64) {
  $arch = ""
  if ($standalone) {
    if ($is64) {
      $arch = "x64"
    }
    else {
      $arch = "x86"
    }
  }
  else {
    $arch = ("x86", "x64")[[Environment]::Is64BitOperatingSystem]
  }
  $nodeInstaller = ""
  if ($standalone) {
    $nodeInstaller = "node-$($version)-win-$($arch).zip"
  }
  else {
    $nodeInstaller = "node-$($version)-$($arch).msi"
  }
  $nodeInstallerPath = "$($env:TEMP)\$($nodeInstaller)"
  $url = "https://nodejs.org/dist/$($version)/$($nodeInstaller)"
  Invoke-WebRequest -Uri $url -OutFile $nodeInstallerPath
  return $nodeInstallerPath
}

function getNodePath() {
  $nodePath = where.exe /Q "node.exe"
  if ($null -ne $nodePath) {
    return $nodePath
  }
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
  $npmPath = where.exe "npm.cmd"
  if ($null -ne $npmPath) {
    return $npmPath
  }
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