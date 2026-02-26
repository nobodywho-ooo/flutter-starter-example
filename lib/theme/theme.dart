import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

extension CustomColorExtension on ShadColorScheme {
  Color get surfaceMessage => custom['surfaceMessage']!;
}
