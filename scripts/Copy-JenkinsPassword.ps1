$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$credential = Import-Clixml (Join-Path $taskRoot 'jenkins\admin-credential.xml')
Set-Clipboard -Value $credential.GetNetworkCredential().Password
Write-Host 'Jenkins login: admin. Password copied to clipboard. Paste it into http://127.0.0.1:8090/ and clear the clipboard afterward.'
