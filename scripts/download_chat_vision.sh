#!/bin/bash
# Download chat and projection models for macOS and Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_DIR/assets"

CHAT_URL="https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/main/Qwen3VL-2B-Instruct-Q4_K_M.gguf"
PROJECTION_URL="https://huggingface.co/Qwen/Qwen3-VL-2B-Instruct-GGUF/resolve/main/mmproj-Qwen3VL-2B-Instruct-Q8_0.gguf"

CHAT_OUTPUT="$ASSETS_DIR/chat-model.gguf"
PROJECTION_OUTPUT="$ASSETS_DIR/projection-model.gguf"

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

download "$CHAT_URL" "$CHAT_OUTPUT" "chat model"
download "$PROJECTION_URL" "$PROJECTION_OUTPUT" "projection model"
