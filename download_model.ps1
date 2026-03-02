# Download Qwen3-0.6B GGUF model for Windows (PowerShell)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$assetsDir = Join-Path $scriptDir "assets"
$url = "https://huggingface.co/bartowski/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf"
$output = Join-Path $assetsDir "model.gguf"

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

Write-Host "Downloading Qwen3-0.6B Q4_K_M model..."
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
Write-Host "Done. Model saved to $output"
