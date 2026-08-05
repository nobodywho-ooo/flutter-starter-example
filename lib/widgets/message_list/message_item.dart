import 'package:flutter/material.dart';
import 'package:flutter_starter_example/models/models.dart';
import 'package:flutter_starter_example/theme/theme.dart';
import 'package:flutter_starter_example/widgets/message_list/highlight_text.dart';
import 'package:flutter_starter_example/widgets/message_list/tts_button.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.message, required this.isLast});

  final AiMessage message;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;
    final backgroundColor = theme.colorScheme.surfaceMessage;

    final id = hashCode.toString();
    final content = message.content;

    return switch (message) {
      AiSystemMessage() => Center(
        key: Key(id),
        child: Container(
          margin: Spacings.xs.vertical,
          padding: Spacings.md.horizontal + Spacings.sm.vertical,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: textTheme.p.copyWith(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ),
      AiAssistantMessage() => Padding(
        key: Key(id),
        padding:
            Spacings.md.horizontal +
            (isLast ? Spacings.zero.vertical : Spacings.xxl.vertical),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            GptMarkdown(
              content,
              style: textTheme.p,
              highlightBuilder: (context, text, style) =>
                  HighlightText(text: text, style: style),
            ),
            Spacings.sm.verticalSpace,
            TtsButton(text: content),
          ],
        ),
      ),
      AiUserMessage() => Align(
        key: Key(id),
        alignment: Alignment.centerRight,
        child: Container(
          margin: Spacings.xs.horizontal + Spacings.sm.horizontal,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.85,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: Spacings.lg.horizontal + Spacings.sm.vertical,
            child: Text(content, style: textTheme.p),
          ),
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
