# Download embedding and reranker models for Windows (PowerShell)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir
$assetsDir = Join-Path $projectDir "assets"

$embeddingUrl = "https://huggingface.co/CompendiumLabs/bge-small-en-v1.5-gguf/resolve/main/bge-small-en-v1.5-q8_0.gguf"
$rerankerUrl = "https://huggingface.co/gpustack/bge-reranker-v2-m3-GGUF/resolve/main/bge-reranker-v2-m3-Q8_0.gguf"

$embeddingOutput = Join-Path $assetsDir "embedding-model.gguf"
$rerankerOutput = Join-Path $assetsDir "reranker-model.gguf"

if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir | Out-Null
}

Write-Host "Downloading embedding model..."
Invoke-WebRequest -Uri $embeddingUrl -OutFile $embeddingOutput -UseBasicParsing
Write-Host "Done. Embedding model saved to $embeddingOutput"

Write-Host "Downloading reranker model..."
Invoke-WebRequest -Uri $rerankerUrl -OutFile $rerankerOutput -UseBasicParsing
Write-Host "Done. Reranker model saved to $rerankerOutput"
