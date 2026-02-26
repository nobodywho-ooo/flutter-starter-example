import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const HighlightText({super.key, required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontWeight: FontWeight.bold,
        fontSize: style.fontSize != null ? style.fontSize! * 0.9 : 13.5,
        height: style.height,
      ),
    );
  }
}
