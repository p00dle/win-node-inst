Set-Alias -Name log -Value Write-Host

function pause {
  param([string]$message = "Press enter to continue")
  Read-Host -Prompt "$message"
}
function exitWithError($exitcode, $message) {
  log $message
  pause
  $host.SetShouldExit($exitcode)
  exit $exitcode
}

function makeStandaloneAppDataDir($standalone) {
  if (-Not $standalone) {
    return
  }
  if (-Not (Test-Path "$($env:APPDATA)\win-node-inst")) {
    & mkdir "$($env:APPDATA)\win-node-inst" | Out-Null
  }
  if (-Not (Test-Path "$($env:APPDATA)\win-node-inst\node")) {
    & mkdir "$($env:APPDATA)\win-node-inst\node" | Out-Null
  }
  if (-Not (Test-Path "$($env:APPDATA)\win-node-inst\git")) {
    & mkdir "$($env:APPDATA)\win-node-inst\git" | Out-Null
  }
}