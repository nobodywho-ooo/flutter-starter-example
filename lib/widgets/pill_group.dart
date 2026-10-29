import 'package:material_ui/material_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:flutter_starter_example/widgets/pill.dart';

class PillGroup extends StatelessWidget {
  const PillGroup({super.key, required this.options});

  final List<({String label, double? probability})> options;

  @override
  Widget build(BuildContext context) {
    final probabilities = options.map((o) => o.probability).nonNulls;
    final best = probabilities.isEmpty
        ? null
        : probabilities.reduce((a, b) => a > b ? a : b);

    return Wrap(
      spacing: Spacings.sm.value,
      runSpacing: Spacings.sm.value,
      children: [
        for (final option in options)
          Pill(
            label: option.label,
            probability: option.probability,
            highlighted: best != null && option.probability == best,
          ),
      ],
    );
  }
}
