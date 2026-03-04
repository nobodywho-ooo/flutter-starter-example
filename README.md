![Nobody Who](./preview.png)

[![Discord](https://img.shields.io/discord/1308812521456799765?logo=discord&style=flat-square)](https://discord.gg/qhaMc2qCYB)
[![Matrix](https://img.shields.io/badge/Matrix-000?logo=matrix&logoColor=fff)](https://matrix.to/#/#nobodywho:matrix.org)
[![Mastodon](https://img.shields.io/badge/Mastodon-6364FF?logo=mastodon&logoColor=fff&style=flat-square)](https://mastodon.gamedev.place/@nobodywho)
[![Docs](https://img.shields.io/badge/Docs-lightblue?style=flat-square)](https://docs.nobodywho.ooo)

# NobodyWho Flutter Starter App

This starter app demonstrates the capabilities of **[NobodyWho](https://github.com/nobodywho-ooo/nobodywho)**, a library designed to run LLMs locally and efficiently on any device.

## Purpose

This example app illustrates:
- How to integrate the library into your project
- How to chat with a model
- How to deal with embeddings, rerank and RAG

The app has been tested and confirmed to work on **iOS, Android, and macOS**, and it should also work on **Linux and Windows**. Flutter web is not currently supported.

---

## Getting Started

### 1. Install Dependencies

Run the following command to install the required dependencies:
```bash
flutter pub get
```
This project uses common libraries such as `get_it` and `path_provider`.

### 2. Download Models

#### Automated Download (Recommended)
- **macOS/Linux**: Run `./scripts/download_chat_model.sh && ./scripts/download_embedding_rerank.sh`
- **Windows**: Run `.\scripts\download_chat_model.ps1; .\scripts\download_embedding_rerank.ps1`

`download_chat_model` will automatically download the [Qwen3-0.6B model](https://huggingface.co/bartowski/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf), rename it to `chat-model.gguf`, and place it in the `assets` folder.

`download_embedding_rerank`, it will download for you [bge-small-en-v1.5](https://huggingface.co/CompendiumLabs/bge-small-en-v1.5-gguf/resolve/main/bge-small-en-v1.5-q8_0.gguf) and [bge-reranker-v2-m3-Q8_0](https://huggingface.co/gpustack/bge-reranker-v2-m3-GGUF/resolve/main/bge-reranker-v2-m3-Q8_0.gguf), place them in the `assets` folder and rename them `embedding-model.gguf` / `reranker-model.gguf`.

Note: if you don't want to try embeddings and rerank/rag, you can simply skip `download_embedding_rerank` script.

#### Manual Download

Alternatively, you can manually download `.gguf` model from Hugging Face. However, not all models are guaranteed to work out of the box, and some may require a powerful machine.

### 3. Run the App

Start the app with:
```bash
flutter run
```

Or specify a specific platform:
```bash
flutter run -d macos
```

---

## Notes

- **Singleton Usage**: For optimal performance, the NobodyWho engine should be used as a singleton. This example uses `get_it`, but you can replace it with your preferred dependency injection solution.
- Make sure to delete the app from the simulator/testing device everytime you change a model.

---

## Feedback & Contributions

We welcome your feedback and ideas!

- **Bug Reports & Improvements**: If you encounter a bug or have suggestions for improving this example app, please open an issue on our **[Issues](https://github.com/nobodywho-ooo/flutter-starter-example/issues)** page.
- **Feature Requests & Questions**: For new feature requests or general questions, join the discussion on our **[Discussions](https://github.com/nobodywho-ooo/flutter-starter-example/discussions)** page.
