import 'package:flutter/material.dart';
import 'package:ruang_shalat/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._(); // Prevent instantiation

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.emeraldGreen,
        ),
        useMaterial3: true,
      );
}
