import 'package:flutter/material.dart';
import 'package:flutter_starter_example/screens/chat/chat_view.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final aiRepository = getIt<AiRepository>();
  bool _errorInit = false;
  bool _runningInit = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _errorInit = false;
      _runningInit = true;
    });

    // Avoid blocking drawer animation if your model is big
    await Future.delayed(const Duration(seconds: 1));

    try {
      await aiRepository.loadChatModel();
      aiRepository.createChat();

      setState(() {
        _runningInit = false;
      });
    } catch (err) {
      debugPrint("Error loadChatModel $err");
      setState(() {
        _errorInit = true;
        _runningInit = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorInit) {
      return ErrorIndicator(
        retry: _init,
        message: 'Error during initialization',
      );
    }

    if (_runningInit) {
      return LoadingIndicator();
    }

    return ChatView();
  }
}
