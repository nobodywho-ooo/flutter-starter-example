import 'package:flutter/material.dart';
import 'package:flutter_starter_example/widgets/message_list/widgets/highlight_text.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StreamingMessageItem extends StatelessWidget {
  final String content;

  const StreamingMessageItem({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
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
}
