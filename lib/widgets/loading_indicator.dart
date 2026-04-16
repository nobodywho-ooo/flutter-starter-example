import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      mainAxisAlignment: .center,
      crossAxisAlignment: .center,
      children: [
        CircularProgressIndicator(color: Colors.blueGrey),
        SizedBox(height: 20),
        Center(child: Text("Loading...", style: textTheme.large)),
      ],
    );
  }
}
