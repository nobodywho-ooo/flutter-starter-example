# Download chat and projection models for Windows (PowerShell)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$assetsDir = Join-Path $projectDir "assets"

$chatUrl = "https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/main/Qwen3VL-2B-Instruct-Q4_K_M.gguf"
$projectionUrl = "https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/main/mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf"

$chatOutput = Join-Path $assetsDir "chat-model.gguf"
$projectionOutput = Join-Path $assetsDir "projection-model.gguf"

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

Write-Host "Downloading chat model..."
Invoke-WebRequest -Uri $chatUrl -OutFile $chatOutput -UseBasicParsing
Write-Host "Done. chat model saved to $chatOutput"

Write-Host "Downloading projection model..."
Invoke-WebRequest -Uri $projectionUrl -OutFile $projectionOutput -UseBasicParsing
Write-Host "Done. Projection model saved to $projectionOutput"
