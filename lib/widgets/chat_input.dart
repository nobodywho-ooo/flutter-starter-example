import 'package:flutter/material.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:flutter_starter_example/widgets/stt_button.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _iconButtonSize = 26.0;
final _contentPadding = Spacings.lg.horizontal + Spacings.md.vertical;

InputBorder _getBorder() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 1.0),
  );
}

class ChatInput extends StatelessWidget {
  const ChatInput({
    super.key,
    required this.controller,
    required this.responding,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool responding;
  final VoidCallback onSend;
  final VoidCallback onStop;

  void _handleSubmit() {
    if (controller.text.trim().isNotEmpty && !responding) {
      onSend();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;
    final hintText = responding
        ? 'Waiting for response...'
        : 'Type a message...';

    return Padding(
      padding: Spacings.md.horizontal + Spacings.xs.top + Spacings.xl.bottom,
      child: Row(
        crossAxisAlignment: .end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.border, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: controller,
                    enabled: !responding,
                    decoration: InputDecoration(
                      hintStyle: theme.textTheme.p,
                      hintText: hintText,
                      enabledBorder: _getBorder(),
                      focusedBorder: _getBorder(),
                      disabledBorder: _getBorder(),
                      contentPadding: _contentPadding,
                    ),
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _handleSubmit(),
                    textInputAction: TextInputAction.send,
                  ),
                  Padding(
                    padding:
                        Spacings.lg.horizontal +
                        Spacings.sm.vertical +
                        Spacings.sm.bottom,
                    child: Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        SttButton(
                          controller: controller,
                          size: _iconButtonSize,
                          enabled: !responding,
                        ),
                        if (responding)
                          Padding(
                            padding: Spacings.xs.bottom,
                            child: GestureDetector(
                              onTap: onStop,
                              child: Icon(
                                LucideIcons.circleStop,
                                color: Colors.red,
                                size: _iconButtonSize,
                              ),
                            ),
                          )
                        else
                          ListenableBuilder(
                            listenable: controller,
                            builder: (_, child) {
                              final enabled = controller.text != '';
                              final onPressed =
                                  controller.text.trim().isNotEmpty
                                  ? onSend
                                  : null;

                              return GestureDetector(
                                onTap: onPressed,
                                child: Icon(
                                  LucideIcons.send,
                                  color: enabled
                                      ? Colors.blueGrey
                                      : Colors.grey,
                                  size: _iconButtonSize,
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
