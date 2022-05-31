

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
function getGitDownloadUrl($standalone, $is64) {
  if ($standalone) {
    $html = Invoke-WebRequest -Uri "https://git-scm.com/download/win"
    $arch = ("32", "64")[$is64]
    $regex = "https://github.com/git-for-windows/git/releases/download/v\d+\.\d+\.\d+\.windows\.1/PortableGit-\d+\.\d+\.\d+-$($arch)-bit.7z.exe"
    $match = Select-String -InputObject $html -Pattern $regex
    return $match.Matches[0].Value
  }
  else {
    $html = Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/latest"
    $arch = ("32", "64")[[Environment]::Is64BitOperatingSystem]
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
