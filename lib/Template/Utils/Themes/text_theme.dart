import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Constant/colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme get light => TextTheme(
    displayLarge: TextStyle(
      fontSize: _fontSize(24, min: 20),
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    displayMedium: TextStyle(
      fontSize: _fontSize(20, min: 18),
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    displaySmall: TextStyle(
      fontSize: _fontSize(18, min: 16),
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    headlineLarge: TextStyle(
      fontSize: _fontSize(20, min: 18),
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    headlineMedium: TextStyle(
      fontSize: _fontSize(18, min: 16),
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    headlineSmall: TextStyle(
      fontSize: _fontSize(16, min: 14),
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    titleLarge: TextStyle(
      fontSize: _fontSize(16, min: 14),
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    titleMedium: TextStyle(
      fontSize: _fontSize(14, min: 12),
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    titleSmall: TextStyle(
      fontSize: _fontSize(13, min: 11),
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    bodyLarge: TextStyle(
      fontSize: _fontSize(14, min: 12),
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(
      fontSize: _fontSize(13, min: 11),
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
    ),
    bodySmall: TextStyle(
      fontSize: _fontSize(11, min: 10),
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      fontFamily: 'Inter',
    ),
    labelLarge: TextStyle(
      fontSize: _fontSize(12, min: 11),
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
      fontFamily: 'Inter',
      letterSpacing: 1.1,
    ),
    labelMedium: TextStyle(
      fontSize: _fontSize(11, min: 10),
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      fontFamily: 'Inter',
    ),
    labelSmall: TextStyle(
      fontSize: _fontSize(10, min: 10),
      fontWeight: FontWeight.w400,
      color: AppColors.textHint,
      fontFamily: 'Inter',
    ),
  );

  static double _fontSize(double size, {double min = 10.0}) {
    return math.max(size.sp, min);
  }
}
