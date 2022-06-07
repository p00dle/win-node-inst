$packageJsonPath = "./app/package.json"

function getAppVersion() {
  if (Test-Path $packageJsonPath) {
    $content = Get-Content $packageJsonPath
    $match = Select-String -InputObject $content -Pattern '"version": "(?<version>[^"]+)'
    if ($null -eq $match) {
      return $null
    }
    else {
      return $match.Matches[0].Groups['version'].Value
    }
  }
  else {
    return $null
  }
}