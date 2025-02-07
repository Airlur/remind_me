import 'package:flutter/material.dart';
import 'package:remind_me/theme/app_colors.dart';

class AppTheme {

  // 浅色模式
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
      surfaceContainer: AppColors.surfaceContainer,
    );

    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceTint,
      
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.onSurface),
        bodyMedium: TextStyle(color: AppColors.onSurface),
        titleLarge: TextStyle(color: AppColors.onSurface),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  // 深色模式
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      surface: AppColors.onSurface,
      surfaceContainer: AppColors.surfaceContainerDark,
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceTintDark,
      
      cardTheme: CardTheme(
        color: AppColors.onSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.onSurfaceDark,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.onSurfaceDark),
        bodyMedium: TextStyle(color: AppColors.onSurfaceDark),
        titleLarge: TextStyle(color: AppColors.onSurfaceDark),
      ),
      
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),
    );
  }
} 