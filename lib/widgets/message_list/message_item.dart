import 'package:flutter/material.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/theme/theme.dart';
import 'package:flutter_starter_example/widgets/message_list/highlight_text.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessageItem extends StatelessWidget {
  final AiMessage message;
  final bool isLast;

  const MessageItem({super.key, required this.message, required this.isLast});

  @override
  Widget build(BuildContext context) {
    if (message is AiDefaultMessage) {
      final theme = ShadTheme.of(context);
      final textTheme = theme.textTheme;
      final backgroundColor = theme.colorScheme.surfaceMessage;

      final id = hashCode.toString();
      final content = message.content;

      return switch (message.role) {
        AiRole.system => Center(
          key: Key(id),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              content,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12.0),
            ),
          ),
        ),
        AiRole.assistant => Padding(
          key: Key(id),
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: isLast ? 0 : 40,
          ),
          child: GptMarkdown(
            content,
            style: textTheme.p,
            highlightBuilder: (context, text, style) =>
                HighlightText(text: text, style: style),
          ),
        ),
        _ => Align(
          key: Key(id),
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Text(content, style: textTheme.p),
            ),
          ),
        ),
      };
    }

    // Other types are irrelevant for now
    return SizedBox.shrink();
  }
}
