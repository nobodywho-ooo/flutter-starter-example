import 'package:flutter/material.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/widgets/message_list/message_item.dart';
import 'package:flutter_starter_example/widgets/message_list/streaming_message_item.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessageList extends StatefulWidget {
  final List<AiMessage> messages;
  final bool thinking;
  final String? streamingContent;

  const MessageList({
    super.key,
    required this.messages,
    required this.thinking,
    this.streamingContent,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll when new messages arrive or streaming content updates
    if (widget.messages.length > oldWidget.messages.length ||
        widget.streamingContent != oldWidget.streamingContent) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildEmptyChatView(ShadTextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Icon(LucideIcons.messageSquare, size: 48, color: Colors.blueGrey),
          const SizedBox(height: 16),
          Text('Start a conversation', style: textTheme.p),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final streamingContent = widget.streamingContent;
    final messages = widget.messages;

    final hasStreamingContent =
        streamingContent != null && streamingContent.isNotEmpty;
    final totalItems = messages.length + (streamingContent != null ? 1 : 0);

    if (messages.isEmpty && !hasStreamingContent) {
      return _buildEmptyChatView(theme.textTheme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index < messages.length) {
          return MessageItem(
            message: messages[index],
            isLast: totalItems == index - 1,
          );
        } else {
          if (widget.thinking) {
            return Align(
              alignment: AlignmentGeometry.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 0, 20),
                child: Row(
                  children: [
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(width: 8),
                    Text("Thinking...", style: theme.textTheme.p),
                  ],
                ),
              ),
            );
          }
          return StreamingMessageItem(
            content: streamingContent ?? '',
            isLast: totalItems == index - 1,
          );
        }
      },
    );
  }
}
