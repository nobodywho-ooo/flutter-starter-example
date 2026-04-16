import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';

class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({super.key, this.retry, this.message});

  final VoidCallback? retry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        Center(
          child: Padding(
            padding: Spacings.lg.horizontal,
            child: Column(
              children: [
                Text("Something wrong happened :/", style: textTheme.large),
                if (message case final message?)
                  Text(
                    message,
                    textAlign: .center,
                    style: textTheme.p.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        if (retry case final retry?)
          ShadButton(onPressed: retry, child: const Text('Try again')),
      ],
    );
  }
}
