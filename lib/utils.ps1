Set-Alias -Name log -Value Write-Host

function pause {
  param([string]$message = "Press enter to continue")
  Read-Host -Prompt "$message"
}
function ExitWithError($exitcode, $message) {
  log $message
  pause
  $host.SetShouldExit($exitcode)
  exit $exitcode
}