![Nobody Who](./preview.png)

[![Discord](https://img.shields.io/discord/1308812521456799765?logo=discord&style=flat-square)](https://discord.gg/qhaMc2qCYB)
[![Matrix](https://img.shields.io/badge/Matrix-000?logo=matrix&logoColor=fff)](https://matrix.to/#/#nobodywho:matrix.org)
[![Mastodon](https://img.shields.io/badge/Mastodon-6364FF?logo=mastodon&logoColor=fff&style=flat-square)](https://mastodon.gamedev.place/@nobodywho)
[![Docs](https://img.shields.io/badge/Docs-lightblue?style=flat-square)](https://docs.nobodywho.ooo)

# NobodyWho Flutter Starter App

This starter app demonstrates the capabilities of **[NobodyWho](https://github.com/nobodywho-ooo/nobodywho)**, a library designed to run LLMs locally and efficiently on any device.

## Features

- **Chat** — stream responses from a local LLM
- **Tool calling** — give the model access to custom functions (e.g. weather, calculator)
- **Vision & Hearing** — image & audio ingestion with a multimodal model
- **Embeddings & RAG** — semantic search with an embedding model and cross-encoder reranker

The app has been tested on **iOS, Android, and macOS**, and should also work on **Linux and Windows**. Flutter Web is not currently supported.

---

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Download Models

#### Automated (Recommended)

**Chat only** (minimal setup):

| Platform       | Command                              |
|----------------|--------------------------------------|
| macOS / Linux  | `./scripts/download_chat.sh`   |
| Windows        | `.\scripts\download_chat.ps1`  |

**All features** (chat + vision + embeddings + reranker):

| Platform       | Command                                                                               |
|----------------|---------------------------------------------------------------------------------------|
| macOS / Linux  | `./scripts/download_chat_multimodal.sh && ./scripts/download_embedding_rerank.sh`         |
| Windows        | `.\scripts\download_chat_multimodal.ps1; .\scripts\download_embedding_rerank.ps1`         |

The scripts download models from Hugging Face, rename them, and place them in the `assets/` folder.

#### Manual Download

You can use any `.gguf` model from Hugging Face. Keep in mind:

- **Tool calling**: the chat model must support function/tool calling.
- **Vision**: the chat model and vision model must be compatible with each other.

### 3. Run the App

```bash
flutter run
```

Or target a specific platform:

```bash
flutter run -d ios
flutter run -d android
flutter run -d macos
```

---

## Notes

- **Singleton**: Keep the NobodyWho engine as a singleton. This example uses `get_it`, but any DI solution works.
- **Model changes**: After swapping a model file, delete the app from the simulator/device so the old cached model is cleared. `flutter clean` can also help.
- **iOS / macOS native assets**: If you see an error about `objective_c.dylib` not loading, make sure you have run `flutter config --enable-native-assets` and rebuilt the app.

---

## Feedback & Contributions

We welcome your feedback and ideas!

- **Bug Reports & Improvements**: Open an issue on the **[Issues](https://github.com/nobodywho-ooo/flutter-starter-example/issues)** page.
- **Feature Requests & Questions**: Join the discussion on **[Discussions](https://github.com/nobodywho-ooo/flutter-starter-example/discussions)**.
