import 'package:flutter/material.dart';
import 'package:remind_me/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardTheme(
        color: AppColors.lightCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.lightTextColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextColor,
          fontSize: 14,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.lightTextColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardTheme(
        color: AppColors.darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 14,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: AppColors.darkTextColor,
      ),
    );
  }
} 