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
    final text = _textController.text.trim();
    if (text.isEmpty || chat == null || _responding) return;

    if (chat case final chat?) {
      setState(() {
        _messages.add(AiMessage.message(role: AiRole.user, content: text));
        _responding = true;
        _streamingContent = '';
      });
      _textController.clear();

      try {
        final responseStream = chat.ask(text);

        await for (final token in responseStream) {
          if (!mounted) return;
          setState(() {
            _streamingContent =
                (_streamingContent ?? '') +
                token.replaceAll(RegExp(r'</?think>'), '');
          });
        }

        // Streaming complete - fetch the actual chat history from the backend
        // This ensures we have the correct messages including any tool calls/responses
        if (mounted) {
          final history = await chat.getChatHistory();
          List<AiMessage> messages = [];
          for (var message in history) {
            // TODO: do the same for others messages
            messages.add(
              AiMessage.message(
                role: message.role,
                content: message.content.replaceAll(RegExp(r'</?think>'), ''),
              ),
            );
          }
          setState(() {
            // Keep the initial system message, replace the rest with actual history
            _messages.clear();
            _messages.addAll(messages);
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
        title: Text("Chat", style: theme.textTheme.h3),
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
