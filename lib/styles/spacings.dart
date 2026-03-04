import 'package:flutter/widgets.dart';

abstract class Spacings {
  static const zero = Spacing._(0);
  static const xxs = Spacing._(2);
  static const xs = Spacing._(4);
  static const sm = Spacing._(8);
  static const md = Spacing._(12);
  static const lg = Spacing._(16);
  static const xl = Spacing._(20);
  static const xxl = Spacing._(32);
  static const xxxl = Spacing._(48);
  static const xxxxl = Spacing._(64);
}

class Spacing {
  const Spacing._(this.value);

  final double value;

  EdgeInsetsDirectional get all => EdgeInsetsDirectional.all(value);

  EdgeInsetsDirectional get horizontal =>
      EdgeInsetsDirectional.symmetric(horizontal: value);
  EdgeInsetsDirectional get vertical =>
      EdgeInsetsDirectional.symmetric(vertical: value);

  EdgeInsetsDirectional get start => EdgeInsetsDirectional.only(start: value);
  EdgeInsetsDirectional get top => EdgeInsetsDirectional.only(top: value);
  EdgeInsetsDirectional get end => EdgeInsetsDirectional.only(end: value);
  EdgeInsetsDirectional get bottom => EdgeInsetsDirectional.only(bottom: value);

  SizedBox get horizontalSpace => SizedBox(width: value);
  SizedBox get verticalSpace => SizedBox(height: value);
}
