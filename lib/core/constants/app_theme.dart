import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgOffWhite,
      primaryColor: AppColors.primaryYellow,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: AppColors.textBlack,
        ),
        iconTheme: IconThemeData(
          color: AppColors.textBlack,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: AppColors.textBlack,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.textBlack,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textBlack,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textBlack,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.borderBlack,
        secondary: AppColors.lavenderPurple,
        surface: AppColors.cardWhite,
      ),
    );
  }
}
