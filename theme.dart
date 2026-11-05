import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF14283D);
  static const navy2 = Color(0xFF203B53);
  static const gold = Color(0xFFD6AD60);
  static const ivory = Color(0xFFF5F3ED);
  static const emerald = Color(0xFF287C68);
  static const success = Color(0xFF2E9B72);
  static const error = Color(0xFFD65A52);
  static const muted = Color(0xFFAAB4BE);
}

ThemeData buildTheme() {
  const fallback = ['Noto Sans Bengali', 'NotoSansBengali'];
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.navy,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.emerald,
      surface: AppColors.navy2,
      error: AppColors.error,
    ),
    textTheme: base.textTheme.apply(
      fontFamilyFallback: fallback,
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      elevation: 0,
      centerTitle: true,
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
