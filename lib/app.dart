import 'package:flutter/material.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/screens/chat_screen.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      aiRepository.createChat(tools: [circleAreaTool, getWeatherTool]);

      setState(() {
        _appState = .ready;
      });
    } catch (err) {
      debugPrint("Error :$err");

      setState(() {
        _appState = .error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    return switch (_appState) {
      .loading => Scaffold(
        body: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            CircularProgressIndicator(color: Colors.blueGrey),
            SizedBox(height: 20),
            Center(child: Text("Loading...", style: textTheme.large)),
          ],
        ),
      ),
      .error => Scaffold(
        body: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Center(
              child: Padding(
                padding: Spacings.lg.horizontal,
                child: Column(
                  children: [
                    Text("Something wrong happened :/", style: textTheme.large),
                    Text(
                      "Make sure you have downloaded a chat model",
                      textAlign: .center,
                      style: textTheme.p.copyWith(
                        color: theme.colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            ShadButton(
              onPressed: _loadChatModel,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
      .ready => ChatScreen(),
    };
  }
}
