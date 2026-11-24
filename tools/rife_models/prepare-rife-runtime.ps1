# SPDX-License-Identifier: GPL-3.0-only
[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$OutputDirectory)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$out = [System.IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force $out | Out-Null
$work = Join-Path ([System.IO.Path]::GetTempPath()) ('veyra-rife-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $work | Out-Null
try {
    $seven = (Get-Command 7z.exe -ErrorAction SilentlyContinue).Source
    if (!$seven) { $seven = Join-Path $env:ProgramFiles '7-Zip/7z.exe' }
    if (!(Test-Path $seven)) { throw '7-Zip nao encontrado.' }
    $models = @('rife_v4.26', 'rife_v4.22_lite')
    $inputs = Join-Path $work 'inputs'
    New-Item -ItemType Directory -Force (Join-Path $inputs 'rife_v2') | Out-Null
    foreach ($name in $models) {
        $archive = Join-Path $work "$name.7z"
        $extract = Join-Path $work $name
        Invoke-WebRequest -Uri "https://github.com/AmusementClub/vs-mlrt/releases/download/external-models/$name.7z" -OutFile $archive
        Write-Host "SHA256 de origem: $name $((Get-FileHash $archive).Hash)"
        & $seven x $archive "-o$extract" -y
        if ($LASTEXITCODE -ne 0) { throw "Falha 7-Zip: $name" }
        $candidates = @(Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "$name.onnx" | Where-Object { $_.Directory.Name -eq 'rife_v2' })
        if ($candidates.Count -ne 1) { throw "Esperava um modelo v2 de $name; encontrados: $($candidates.Count)" }
        Copy-Item -LiteralPath $candidates[0].FullName -Destination (Join-Path $inputs "rife_v2/$name.onnx")
    }
    $venv = Join-Path $work 'venv'
    python -m venv $venv
    $py = Join-Path $venv 'Scripts/python.exe'
    & $py -m pip install --disable-pip-version-check 'onnx==1.20.1' 'onnxruntime==1.24.4'
    & $py (Join-Path $PSScriptRoot 'make_rife_models.py') $inputs $out
    & $py (Join-Path $PSScriptRoot 'verify-rife-runtime.py') $out
    & (Join-Path $root 'scripts/ci/fetch-rife-gaming.ps1') -Root $root -RuntimeDirectory $out
    foreach ($file in @('onnxruntime.dll','onnxruntime_providers_shared.dll','DirectML.dll','rife_v4.26_fp16.onnx','rife_v4.22_lite_fp16.onnx')) {
        $path = Join-Path $out $file
        if (!(Test-Path -LiteralPath $path -PathType Leaf) -or (Get-Item -LiteralPath $path).Length -eq 0) { throw "Runtime ausente: $file" }
        Write-Host "$file $((Get-FileHash $path).Hash)"
    }
    Write-Host 'Runtime preparado. A validacao de GPU deve ser realizada no Veyra.'
} finally {
    Remove-Item -LiteralPath $work -Recurse -Force
}
