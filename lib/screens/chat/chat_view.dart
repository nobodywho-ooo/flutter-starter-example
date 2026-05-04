import 'package:flutter/material.dart';
import 'package:flutter_starter_example/helpers/helpers.dart';
import 'package:flutter_starter_example/service_locator.dart';
import 'package:flutter_starter_example/repositories/repositories.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:flutter_starter_example/widgets/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final chat = getIt<AiRepository>().chat;
  final List<AiMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  String? _streamingContent;
  String? _inferenceStats;
  bool _responding = false;
  bool _thinking = false;

  @override
  void initState() {
    super.initState();
    // System message example
    // _messages.add(
    //   AiMessage.system(
    //     content: 'Chat ready. Send a message to begin!',
    //   ),
    // );
  }

  Future<void> _sendMessage() async {
    final userInput = _textController.text.trim();

    if (userInput.isEmpty || chat == null || _responding) return;

    if (chat case final chat?) {
      setState(() {
        _messages.add(AiMessage.user(content: userInput));
        _responding = true;
        _thinking = true;
        _streamingContent = '';
      });
      _textController.clear();

      try {
        final tokenStream = skipThinkingTags(chat.ask(userInput));
        final startTime = DateTime.now();
        DateTime? firstTokenTime;
        int tokenCount = 0;

        await for (final token in tokenStream) {
          if (!mounted) return;

          tokenCount++;
          firstTokenTime ??= DateTime.now();

          setState(() {
            _streamingContent = (_streamingContent ?? '') + token;
            _thinking = false;
          });
        }

        // Calculate inference stats
        if (firstTokenTime != null && tokenCount > 0) {
          final ttftMs = firstTokenTime.difference(startTime).inMilliseconds;
          final ttft = ttftMs >= 1000
              ? '${(ttftMs / 1000).toStringAsFixed(1)}s'
              : '${ttftMs}ms';
          final totalMs = DateTime.now()
              .difference(firstTokenTime)
              .inMilliseconds;
          final tokensPerSec = totalMs > 0
              ? (tokenCount / (totalMs / 1000)).toStringAsFixed(1)
              : '-';

          setState(() {
            _inferenceStats = '$tokensPerSec t/s · TTFT $ttft';
          });
          Future.delayed(const Duration(seconds: 8), () {
            if (mounted) {
              setState(() => _inferenceStats = null);
            }
          });
        }

        // Streaming complete - fetch the actual chat history from the backend
        // This delete streaming content and add it to the history so it's display as a normal message list item
        if (mounted) {
          final history = await chat.getChatHistory();
          final List<AiMessage> messages = [];

          for (var message in history) {
            if (message is AiToolMessage) {
              continue;
            }
            if (message is AiAssistantMessage &&
                message.toolCalls != null &&
                message.content.trim().isEmpty) {
              continue;
            }

            messages.add(
              message.copyWith(
                content: message.content
                    .replaceAll(RegExp(r'<think>[\s\S]*?</think>\s*'), '')
                    .trimLeft(),
              ),
            );
          }

          setState(() {
            _messages.clear();
            _messages.addAll(messages);
            _streamingContent = null;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _messages.add(
            AiMessage.assistant(content: 'Error: ${e.toString()}'),
          );
          _streamingContent = null;
        });
      } finally {
        if (mounted) {
          setState(() {
            _responding = false;
            _thinking = false;
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

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: MessageList(
                messages: _messages,
                streamingContent: _streamingContent,
                thinking: _thinking,
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
        if (_inferenceStats case final inferenceStats?)
          Align(
            alignment: AlignmentGeometry.topCenter,
            child: Padding(
              padding: Spacings.sm.top,
              child: ShadBadge.outline(
                backgroundColor: theme.colorScheme.background,
                child: Text(inferenceStats),
              ),
            ),
          ),
      ],
    );
  }
}
