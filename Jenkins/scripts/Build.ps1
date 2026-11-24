param(
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$ArtifactDirectory
)
$ErrorActionPreference = 'Stop'
$taskRoot = Split-Path $PSScriptRoot -Parent
$tools = Join-Path $taskRoot 'tools'
$node = Get-ChildItem $tools -Directory -Filter 'node-v22*-win-x64' | Select-Object -First 1
if (!$node) { throw 'Portable Node.js 22 is missing' }
$env:PATH = $node.FullName + ';' + (Join-Path $tools 'dotnet') + ';' + $env:PATH
$env:DOTNET_ROOT = Join-Path $tools 'dotnet'
$env:DOTNET_CLI_TELEMETRY_OPTOUT = '1'
$env:DOTNET_NOLOGO = '1'
$env:NUGET_PACKAGES = Join-Path $taskRoot 'cache\nuget-packages'
New-Item -ItemType Directory -Force -Path $ArtifactDirectory | Out-Null
$payload = Join-Path $ArtifactDirectory 'payload'
$artifactRoot = [IO.Path]::GetFullPath($ArtifactDirectory).TrimEnd('\') + '\'
if (![IO.Path]::GetFullPath($payload).StartsWith($artifactRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid artifact path' }
if (Test-Path $payload) { Remove-Item -LiteralPath $payload -Recurse -Force }
New-Item -ItemType Directory -Force -Path $payload | Out-Null
Push-Location (Join-Path $Source 'App\zvitplus.app')
try {
    & npm.cmd ci --no-audit --no-fund
    if ($LASTEXITCODE -ne 0) { throw 'npm ci failed' }
    & npm.cmd run build:docker
    if ($LASTEXITCODE -ne 0) { throw 'Frontend build failed' }
    Copy-Item 'dist' (Join-Path $payload 'web') -Recurse
    Copy-Item 'nginx.conf' $payload
} finally { Pop-Location }
& (Join-Path $env:DOTNET_ROOT 'dotnet.exe') publish (Join-Path $Source 'App\ZvitPlus.API\ZvitPlus.API.csproj') -c Release -r linux-x64 --self-contained false -o (Join-Path $payload 'api')
if ($LASTEXITCODE -ne 0) { throw 'Linux API publish failed' }
$revision = & git -C $Source rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot identify source revision' }
@{ commit=$revision; builtAtUtc=[DateTime]::UtcNow.ToString('o'); target='linux-x64'; node=(& node --version); sdk=(& (Join-Path $env:DOTNET_ROOT 'dotnet.exe') --version) } | ConvertTo-Json | Set-Content (Join-Path $payload 'build-info.json') -Encoding UTF8
$archive = Join-Path $ArtifactDirectory 'zvitplus-linux-x64.tar.gz'
& tar.exe -czf $archive -C $payload .
if ($LASTEXITCODE -ne 0) { throw 'Artifact packaging failed' }
$stream = [IO.File]::OpenRead($archive)
try { $hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)).Replace('-','').ToLowerInvariant() } finally { $stream.Dispose() }
$hash | Set-Content ($archive + '.sha256')
Write-Output "Artifact ready: $archive"
