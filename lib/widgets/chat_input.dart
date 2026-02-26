import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _sendButtonSize = 52.0;
const _contentPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final bool responding;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const ChatInput({
    super.key,
    required this.controller,
    required this.responding,
    required this.onSend,
    required this.onStop,
  });

  void _handleSubmit() {
    if (controller.text.trim().isNotEmpty && !responding) {
      onSend();
    }
  }

  InputBorder _getInputBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: color, width: 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;
    final hintText = responding
        ? 'Waiting for response...'
        : 'Type a message...';

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 26),
      child: Row(
        crossAxisAlignment: .end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !responding,
              decoration: InputDecoration(
                hintStyle: theme.textTheme.p,
                hintText: hintText,
                enabledBorder: _getInputBorder(colorScheme.border),
                focusedBorder: _getInputBorder(colorScheme.border),
                disabledBorder: _getInputBorder(colorScheme.muted),
                contentPadding: _contentPadding,
              ),
              minLines: 1,
              maxLines: 20,
              onSubmitted: (_) => _handleSubmit(),
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8.0),
          if (responding)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: ShadIconButton.destructive(
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  final enabled = controller.text != '';
                  final onPressed = controller.text.trim().isNotEmpty
                      ? onSend
                      : null;

                  if (enabled) {
                    return ShadIconButton(
                      height: _sendButtonSize,
                      width: _sendButtonSize,
                      onPressed: onPressed,
                      icon: const Icon(LucideIcons.send),
                    );
                  }

                  return ShadIconButton.secondary(
                    height: _sendButtonSize,
                    width: _sendButtonSize,
                    onPressed: onPressed,
                    icon: const Icon(LucideIcons.send),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
