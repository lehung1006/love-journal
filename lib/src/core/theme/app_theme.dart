import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rose,
        primary: AppColors.rose,
        secondary: AppColors.teal,
        surface: AppColors.surface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.paper,
      splashColor: AppColors.rose.withValues(alpha: .08),
      highlightColor: AppColors.rose.withValues(alpha: .04),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: AppTextStyles.displayXL.copyWith(color: AppColors.ink),
        displayMedium: AppTextStyles.displayL.copyWith(color: AppColors.ink),
        headlineMedium: AppTextStyles.titleL.copyWith(color: AppColors.ink),
        titleMedium: AppTextStyles.titleM.copyWith(color: AppColors.ink),
        bodyLarge: AppTextStyles.bodyL.copyWith(color: AppColors.inkSoft),
        bodyMedium: AppTextStyles.bodyM.copyWith(color: AppColors.inkSoft),
        bodySmall: AppTextStyles.bodyS.copyWith(color: AppColors.muted),
        labelSmall: AppTextStyles.label.copyWith(color: AppColors.roseDark),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line),
    );
  }
}
