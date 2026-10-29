import 'package:material_ui/material_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:flutter_starter_example/theme/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _successColor = Color(0xFF34C759);

String _pct(double p) => '${(p * 100).toStringAsFixed(1)}%';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.probability,
    required this.highlighted,
  });

  final String label;
  final double? probability;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final textTheme = theme.textTheme;
    final textColor = highlighted ? Colors.white : null;

    return Container(
      padding: Spacings.xl.horizontal + Spacings.sm.vertical,
      decoration: BoxDecoration(
        color: highlighted ? _successColor : theme.colorScheme.surfaceMessage,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisSize: .min,
        children: [
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: textTheme.small.copyWith(color: textColor),
          ),
          if (probability case final probability?)
            Text(
              _pct(probability),
              style: textTheme.muted.copyWith(color: textColor),
            ),
        ],
      ),
    );
  }
}
