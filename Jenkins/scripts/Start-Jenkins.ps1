$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$runtime = Join-Path $taskRoot 'jenkins'
$env:JENKINS_HOME = Join-Path $runtime 'home'
$java = Get-ChildItem (Join-Path $runtime 'java') -Recurse -Filter java.exe | Select-Object -First 1
if (!$java) { throw 'Jenkins Java runtime is missing' }
try {
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback,8090)
    $listener.Start()
    $listener.Stop()
} catch { throw 'Port 8090 is in use; Jenkins may already be running at http://127.0.0.1:8090/' }
$process = Start-Process -FilePath $java.FullName -ArgumentList @('-Xms256m','-Xmx768m','-jar',('"'+(Join-Path $runtime 'jenkins.war')+'"'),'--httpListenAddress=127.0.0.1','--httpPort=8090') -WorkingDirectory $runtime -WindowStyle Hidden -RedirectStandardOutput (Join-Path $runtime 'stdout.log') -RedirectStandardError (Join-Path $runtime 'stderr.log') -PassThru
$process.Id | Set-Content (Join-Path $runtime 'jenkins.pid')
Write-Output 'Jenkins: http://127.0.0.1:8090/'
