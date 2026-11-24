[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Root,[string]$RuntimeDirectory)
$ErrorActionPreference = 'Stop'
$rootPath = (Resolve-Path $Root).Path
$deps = Join-Path $rootPath 'deps/ort-dml'
New-Item -ItemType Directory -Force $deps | Out-Null
foreach ($package in @(@{id='microsoft.ml.onnxruntime.directml'; version='1.24.4'; folder='ort'},@{id='microsoft.ai.directml'; version='1.15.4'; folder='dml'})) {
    $archive = Join-Path $deps ($package.id + '.zip')
    $uri = 'https://api.nuget.org/v3-flatcontainer/{0}/{1}/{0}.{1}.nupkg' -f $package.id,$package.version
    Invoke-WebRequest -Uri $uri -OutFile $archive
    Expand-Archive -LiteralPath $archive -DestinationPath (Join-Path $deps $package.folder) -Force
    Remove-Item $archive
}
foreach ($header in @('ort/build/native/include/dml_provider_factory.h','dml/include/DirectML.h')) {
    if (!(Test-Path (Join-Path $deps $header))) { throw "Header ausente: $header" }
}
if ($RuntimeDirectory) {
    New-Item -ItemType Directory -Force $RuntimeDirectory | Out-Null
    foreach ($dll in @('onnxruntime.dll','onnxruntime_providers_shared.dll')) {
        Copy-Item (Join-Path $deps "ort/runtimes/win-x64/native/$dll") $RuntimeDirectory -ErrorAction Stop
    }
    Copy-Item (Join-Path $deps 'dml/bin/x64-win/DirectML.dll') $RuntimeDirectory -ErrorAction Stop
}
Write-Host 'Headers RIFE preparados. Os dois modelos ONNX devem ser obtidos conforme docs/RIFE_DIRECTML.md.'
