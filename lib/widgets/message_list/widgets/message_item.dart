import 'package:flutter/material.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/widgets/message_list/widgets/highlight_text.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessageItem extends StatelessWidget {
  final AiMessage message;

  const MessageItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return switch (message) {
      AiDefaultMessage(:final role, :final content) => _buildDefaultMessage(
        context,
        role,
        content,
      ),
      AiToolCallsMessage(:final toolCalls) => _buildToolCallsMessage(
        context,
        toolCalls,
      ),
      AiToolRespMessage(:final name, :final content) => _buildToolRespMessage(
        context,
        name,
        content,
      ),
    };
  }

  Widget _buildDefaultMessage(
    BuildContext context,
    AiRole role,
    String content,
  ) {
    if (role == AiRole.system) {
      return _buildSystemMessage(context, content);
    } else if (role == AiRole.assistant) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GptMarkdown(
          content,
          style: ShadTheme.of(context).textTheme.p,
          highlightBuilder: (context, text, style) =>
              HighlightText(text: text, style: style),
        ),
      );
    }

    // user
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(content, style: ShadTheme.of(context).textTheme.p),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(BuildContext context, String content) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          content,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12.0),
        ),
      ),
    );
  }

  Widget _buildToolCallsMessage(
    BuildContext context,
    List<AiToolCall> toolCalls,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        color: Colors.blue.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.call_made, size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Tool Calls',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final toolCall in toolCalls) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        toolCall.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toolCall.arguments.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolRespMessage(
    BuildContext context,
    String toolName,
    String result,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.call_received,
                    size: 16,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tool Response: $toolName',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  result,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
