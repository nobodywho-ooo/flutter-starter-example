#!/bin/bash
# Download embedding and reranker models for macOS and Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_DIR/assets"

EMBEDDING_URL="https://huggingface.co/CompendiumLabs/bge-small-en-v1.5-gguf/resolve/main/bge-small-en-v1.5-q8_0.gguf"
RERANKER_URL="https://huggingface.co/gpustack/bge-reranker-v2-m3-GGUF/resolve/main/bge-reranker-v2-m3-Q8_0.gguf"

EMBEDDING_OUTPUT="$ASSETS_DIR/embedding-model.gguf"
RERANKER_OUTPUT="$ASSETS_DIR/reranker-model.gguf"

mkdir -p "$ASSETS_DIR"

download() {
    local url="$1"
    local output="$2"
    local name="$3"

    echo "Downloading $name..."
    if command -v curl &> /dev/null; then
        curl -L -o "$output" "$url"
    elif command -v wget &> /dev/null; then
        wget -O "$output" "$url"
    else
        echo "Error: curl or wget is required." >&2
        exit 1
    fi
    echo "Done. $name saved to $output"
}

download "$EMBEDDING_URL" "$EMBEDDING_OUTPUT" "embedding model"
download "$RERANKER_URL" "$RERANKER_OUTPUT" "reranker model"
