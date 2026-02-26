import 'package:flutter/material.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/screens/chat_screen.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum AppState { loading, error, ready }

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  AppState _modelState = .loading;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _modelState = .loading;
    });

    try {
      await getIt<AiRepository>().loadModel();
      getIt<AiRepository>().createChat(enableTool: true);

      setState(() {
        _modelState = .ready;
      });
    } catch (err) {
      debugPrint("Error :$err");
      setState(() {
        _modelState = .error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;

    return switch (_modelState) {
      .loading => Scaffold(
        body: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            CircularProgressIndicator(),
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
              child: Text(
                "Something wrong happened :/",
                style: textTheme.large,
              ),
            ),
            SizedBox(height: 16),
            ShadButton(onPressed: _loadModel, child: const Text('Try again')),
          ],
        ),
      ),
      .ready => ChatScreen(),
    };
  }
}
