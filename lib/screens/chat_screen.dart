import 'package:flutter/material.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chat = getIt<AiRepository>().chat;
  final List<AiMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  String? _streamingContent;
  bool _responding = false;

  @override
  void initState() {
    super.initState();
    // _messages.add(
    //   AiMessage.message(
    //     role: AiRole.system,
    //     content: 'Chat ready. Send a message to begin!',
    //   ),
    // );
  }

  Future<void> _sendMessage() async {
    final userInput = _textController.text.trim();

    if (userInput.isEmpty || chat == null || _responding) return;

    if (chat case final chat?) {
      setState(() {
        _messages.add(AiMessage.message(role: AiRole.user, content: userInput));
        _responding = true;
        _streamingContent = '';
      });
      _textController.clear();

      try {
        final tokenStream = chat.ask(userInput);

        await for (final token in tokenStream) {
          if (!mounted) return;

          setState(() {
            _streamingContent =
                (_streamingContent ?? '') +
                token.replaceAll(RegExp(r'</?think>'), '');
          });
        }

        // Streaming complete - fetch the actual chat history from the backend
        // This delete streaming content and add it to the history so it's display as a normal message list item
        if (mounted) {
          final history = await chat.getChatHistory();

          setState(() {
            _messages.clear();
            _messages.addAll(history);
            _streamingContent = null;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _messages.add(
            AiMessage.message(
              role: AiRole.assistant,
              content: 'Error: ${e.toString()}',
            ),
          );
          _streamingContent = null;
        });
      } finally {
        if (mounted) {
          setState(() {
            _responding = false;
          });
        }
      }
    }
  }

  void _stopGeneration() {
    chat?.stopGeneration();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat", style: theme.textTheme.h4),
        backgroundColor: theme.colorScheme.background,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: MessageList(
                messages: _messages,
                streamingContent: _streamingContent,
              ),
            ),
            ChatInput(
              controller: _textController,
              responding: _responding,
              onSend: _sendMessage,
              onStop: _stopGeneration,
            ),
          ],
        ),
      ),
    );
  }
}
