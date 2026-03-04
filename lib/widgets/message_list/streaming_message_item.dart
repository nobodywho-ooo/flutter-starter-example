import 'package:flutter/material.dart';
import 'package:flutter_starter_example/widgets/message_list/highlight_text.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StreamingMessageItem extends StatelessWidget {
  final String content;
  final bool isLast;

  const StreamingMessageItem({
    super.key,
    required this.content,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final padding =
        Spacings.md.horizontal +
        (isLast ? Spacings.zero.vertical : Spacings.xxl.vertical);

    return Padding(
      padding: padding,
      child: GptMarkdown(
        content,
        style: ShadTheme.of(context).textTheme.p,
        highlightBuilder: (context, text, style) =>
            HighlightText(text: text, style: style),
      ),
    );
  }
}
