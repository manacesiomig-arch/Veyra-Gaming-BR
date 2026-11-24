# SPDX-License-Identifier: GPL-3.0-only
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$report = Join-Path $root 'DIAGNOSTICO-RIFE.txt'
$lines = New-Object 'System.Collections.Generic.List[string]'
function Line([string]$msg) { $lines.Add($msg); Write-Host $msg }
Line ('Pasta: ' + $root)
Line ('Windows: ' + [Environment]::OSVersion.VersionString)
Line ('PowerShell x64: ' + [Environment]::Is64BitProcess)
$files = @('veyra_qml_ui.exe','runtime\rife\DirectML.dll','runtime\rife\onnxruntime.dll','runtime\rife\onnxruntime_providers_shared.dll','runtime\rife\rife_v4.26_fp16.onnx','runtime\rife\rife_v4.22_lite_fp16.onnx','shaders\RifePack.dxil','shaders\RifeUnpack.dxil','shaders\RifeShotChange.dxil')
$missing = 0
foreach ($name in $files) {
    $file = Join-Path $root $name
    if ((Test-Path -LiteralPath $file -PathType Leaf) -and (Get-Item -LiteralPath $file).Length -gt 0) {
        Line ('OK: ' + $name + ' (' + (Get-Item -LiteralPath $file).Length + ' bytes)')
    } else { Line ('FALTANDO: ' + $name); $missing++ }
}
try { Get-CimInstance Win32_VideoController | ForEach-Object { Line ('GPU: ' + $_.Name + ' | Driver: ' + $_.DriverVersion) } } catch { Line ('GPU: ' + $_.Exception.Message) }
if ($missing -eq 0) {
    try {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class RifeLoader {
 [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)] public static extern IntPtr LoadLibraryEx(string name, IntPtr file, uint flags);
 [DllImport("kernel32.dll", CharSet=CharSet.Ansi, SetLastError=true)] public static extern IntPtr GetProcAddress(IntPtr module, string name);
}
'@
        foreach ($name in @('DirectML.dll','onnxruntime.dll')) {
            $module = [RifeLoader]::LoadLibraryEx((Join-Path $root ('runtime\rife\'+$name)), [IntPtr]::Zero, 0x900)
            $err = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
            if ($module -eq [IntPtr]::Zero) { Line ('ERRO ao carregar ' + $name + ': Win32 ' + $err); continue }
            $symbol = if ($name -eq 'DirectML.dll') { 'DMLCreateDevice' } else { 'OrtGetApiBase' }
            $addr = [RifeLoader]::GetProcAddress($module,$symbol)
            Line ('DLL ' + $name + ' carregada; export ' + $symbol + ': ' + ($addr -ne [IntPtr]::Zero))
        }
    } catch { Line ('Falha no teste de DLL: ' + $_.Exception.Message) }
}
$logDir = Join-Path $root 'logs'
if (Test-Path $logDir) {
    Get-ChildItem -LiteralPath $logDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 3 | ForEach-Object {
        Line ('Log: ' + $_.Name)
        Select-String -LiteralPath $_.FullName -Pattern 'rife|directml|DMLCreateDevice|onnxruntime' | Select-Object -Last 25 | ForEach-Object { Line $_.Line }
    }
}
Line ('Arquivos faltando: ' + $missing)
Line 'Este teste verifica arquivos, DLLs e logs; nao mede inferencia na GPU.'
$lines | Set-Content -LiteralPath $report -Encoding UTF8
Write-Host ('Relatorio salvo: ' + $report)
