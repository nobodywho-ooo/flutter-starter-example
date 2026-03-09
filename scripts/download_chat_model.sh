#!/usr/bin/env bash
# Download chat model for macOS and Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$PROJECT_DIR/assets"
URL="https://huggingface.co/NobodyWho/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf"
OUTPUT="$ASSETS_DIR/chat-model.gguf"

mkdir -p "$ASSETS_DIR"

echo "Downloading chat model..."

if command -v curl &> /dev/null; then
    curl -L -o "$OUTPUT" "$URL"
elif command -v wget &> /dev/null; then
    wget -O "$OUTPUT" "$URL"
else
    echo "Error: curl or wget is required." >&2
    exit 1
fi

echo "Done. Model saved to $OUTPUT"
