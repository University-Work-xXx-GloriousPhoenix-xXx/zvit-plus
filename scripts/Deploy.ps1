param([Parameter(Mandatory=$true)][string]$ArtifactDirectory)
$ErrorActionPreference = 'Stop'
$sshArgs = @('-o','BatchMode=yes','-o','StrictHostKeyChecking=yes','-o','ConnectTimeout=15','-i','C:\Users\Vav1lone\.ssh\developer2_new')
$target = 'developer2@100.77.253.21'
$archive = Join-Path $ArtifactDirectory 'zvitplus-linux-x64.tar.gz'
$expected = (Get-Content ($archive + '.sha256') -Raw).Trim()
$stream = [IO.File]::OpenRead($archive)
try { $actual = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)).Replace('-','').ToLowerInvariant() } finally { $stream.Dispose() }
if ($actual -ne $expected) { throw 'Artifact checksum mismatch' }
& ssh.exe @sshArgs $target 'test -x /usr/local/sbin/zvitplus-deploy'
if ($LASTEXITCODE -ne 0) { throw 'Server helper is not installed; run server-install.sh with sudo once' }
& ssh.exe @sshArgs $target 'mkdir -p /home/developer2/zvitplus-cicd'
if ($LASTEXITCODE -ne 0) { throw 'Cannot create staging directory' }
& scp.exe @sshArgs $archive ($archive + '.sha256') ($target + ':/home/developer2/zvitplus-cicd/')
if ($LASTEXITCODE -ne 0) { throw 'Artifact upload failed' }
$command = 'set -eu; cd /home/developer2/zvitplus-cicd; actual=$(sha256sum zvitplus-linux-x64.tar.gz | cut -d " " -f 1); expected=$(tr -d "\r\n" < zvitplus-linux-x64.tar.gz.sha256); test "$actual" = "$expected"; test "$(pwd -P)" = /home/developer2/zvitplus-cicd; rm -rf -- /home/developer2/zvitplus-cicd/payload; mkdir payload; tar --no-same-owner -xzf zvitplus-linux-x64.tar.gz -C payload; sudo -n /usr/local/sbin/zvitplus-deploy; rm -f -- zvitplus-linux-x64.tar.gz zvitplus-linux-x64.tar.gz.sha256; rm -rf -- /home/developer2/zvitplus-cicd/payload'
$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($command))
& ssh.exe @sshArgs $target ('printf %s ' + $encoded + ' | base64 -d | bash')
if ($LASTEXITCODE -ne 0) { throw 'Server deployment failed; inspect the job console' }
