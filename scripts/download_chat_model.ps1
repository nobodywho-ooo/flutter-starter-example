# Download chat model for Windows (PowerShell)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$assetsDir = Join-Path $projectDir "assets"
$url = "https://huggingface.co/bartowski/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf"
$output = Join-Path $assetsDir "chat-model.gguf"

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

Write-Host "Downloading chat model..."
Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
Write-Host "Done. Model saved to $output"
