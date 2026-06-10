import 'package:flutter/material.dart';

class AppColors {
  static const learnBlue = Color(0xFF4A90D9);
  static const quizGreen = Color(0xFF5CB85C);
  static const spellPurple = Color(0xFF9B59B6);
  static const typeOrange = Color(0xFFF39C12);
  static const skyTop = Color(0xFF87CEEB);
  static const skyBottom = Color(0xFFE8F4FC);
  static const hillGreen = Color(0xFF7CB342);
}

ThemeData buildAppTheme() {
  const seed = AppColors.learnBlue;
  final colorScheme = ColorScheme.fromSeed(seedColor: seed);
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.skyBottom,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 20),
      bodyMedium: TextStyle(fontSize: 18),
      labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(120, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    ),
  );
}
