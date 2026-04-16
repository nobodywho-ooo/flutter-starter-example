import 'package:flutter/material.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/drawer_menu.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

enum AppState { loading, error, ready }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final aiRepository = getIt<AiRepository>();

  AppState _appState = .loading;

  @override
  void initState() {
    super.initState();

    _loadChatModel();
  }

  @override
  void dispose() {
    aiRepository.dispose();
    super.dispose();
  }

  Future<void> _loadChatModel() async {
    setState(() {
      _appState = .loading;
    });

    try {
      await aiRepository.loadChatModel();
      aiRepository.createChat();

      /// Alternative with Tool calling
      /// -> Give your LLM the ability to interact with the outside world and give extra tools
      /// ! Make sure your chat model is compatible !
      /// For e.g: https://huggingface.co/NobodyWho/Qwen_Qwen3-0.6B-GGUF/resolve/main/Qwen_Qwen3-0.6B-Q4_K_M.gguf
      // aiRepository.createToolCallingChat(tools: [circleAreaTool, getWeatherTool]);

      setState(() {
        _appState = .ready;
      });
    } catch (err) {
      debugPrint("_loadChatModel error :$err");

      setState(() {
        _appState = .error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_appState) {
      .loading => Scaffold(body: LoadingIndicator()),
      .error => Scaffold(
        body: ErrorIndicator(
          retry: _loadChatModel,
          message: "Make sure you have downloaded a chat model",
        ),
      ),
      .ready => DrawerMenu(),
    };
  }
}
