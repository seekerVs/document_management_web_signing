import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyle {
  AppStyle._();

  static BoxDecoration card({double radius = 12}) => BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderLight),
      );

  static BoxDecoration statusBadge(Color backgroundColor) => BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(40),
      );
}
