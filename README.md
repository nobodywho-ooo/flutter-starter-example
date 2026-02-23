[![Discord](https://img.shields.io/discord/1308812521456799765?logo=discord&style=flat-square)](https://discord.gg/qhaMc2qCYB)
[![Matrix](https://img.shields.io/badge/Matrix-000?logo=matrix&logoColor=fff)](https://matrix.to/#/#nobodywho:matrix.org)
[![Mastodon](https://img.shields.io/badge/Mastodon-6364FF?logo=mastodon&logoColor=fff&style=flat-square)](https://mastodon.gamedev.place/@nobodywho)
[![Docs](https://img.shields.io/badge/Docs-lightblue?style=flat-square)](https://docs.nobodywho.ooo)

This starter app demonstrate the capabilities of [NobodyWho](https://github.com/nobodywho-ooo/nobodywho), a library that lets you run LLMs locally and efficiently on any device.

The goal of this starter app is to showcase the following :
- how to integrate the library in your project
- how to chat with a model

# Get Started

Install dependencies with `flutter pub get`. This repo use the common librairies like `get_it` and `path_provider`.

Download a compatible LLM model in `.gguf` format, like this [one](https://huggingface.co/bartowski/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf).

Rename it `model.gguf` and place it in `assets` folder.

Then run the app with `flutter run`.