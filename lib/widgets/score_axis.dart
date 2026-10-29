import 'package:material_ui/material_ui.dart';
import 'package:flutter_starter_example/styles/styles.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _axisHeight = 16.0;
const _tickWidth = 2.0;
const _dotSize = 14.0;

class ScoreAxis extends StatelessWidget {
  const ScoreAxis({super.key, required this.levels, this.score});

  final List<String> levels;
  final double? score;

  double _fraction(double index) => index / (levels.length - 1);

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(
          height: _axisHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(height: _tickWidth, color: colorScheme.border),
                  for (var i = 0; i < levels.length; i++)
                    Positioned(
                      left: _fraction(i.toDouble()) * width - _tickWidth / 2,
                      child: Container(
                        width: _tickWidth,
                        height: _axisHeight,
                        color: colorScheme.border,
                      ),
                    ),
                  if (score case final score?)
                    Positioned(
                      left: _fraction(score) * width - _dotSize / 2,
                      child: Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: Spacings.xs.top,
          child: Stack(
            children: [
              for (var i = 0; i < levels.length; i++)
                Align(
                  alignment: Alignment(_fraction(i.toDouble()) * 2 - 1, 0),
                  child: Text(levels[i], style: theme.textTheme.muted),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
