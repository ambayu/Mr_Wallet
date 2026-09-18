import 'package:flutter/material.dart';

class AppColors {
  // Mr Wallet Signature Yellows
  static const Color butterYellow = Color(0xFFFEF3A7);
  static const Color butterYellowDark = Color(0xFFFFDE59);
  static const Color primaryYellow = Color(0xFFFFE86C);
  static const Color accentYellow = Color(0xFFFFD43F);

  // Pastel Palettes from UI Showcase
  static const Color mintGreen = Color(0xFFCEF8BA);
  static const Color mintGreenDark = Color(0xFF86EFAC);
  static const Color bubblePink = Color(0xFFFFCCD5);
  static const Color bubblePinkDark = Color(0xFFF472B6);
  static const Color lavenderPurple = Color(0xFFE4DBFA);
  static const Color skyBlue = Color(0xFFD2EEFC);
  static const Color coralOrange = Color(0xFFFF7A59);
  static const Color softPeach = Color(0xFFFFDEB5);

  // Backgrounds & Neutrals
  static const Color bgCream = Color(0xFFFFFDF8);
  static const Color bgOffWhite = Color(0xFFF9FAFC);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderBlack = Color(0xFF1E1E1E);
  static const Color textBlack = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF71717A);
  static const Color pillGray = Color(0xFFF4F4F5);
  static const Color borderLight = Color(0xFFE4E4E7);

  // Status Colors
  static const Color successGreen = Color(0xFF22C55E);
  static const Color dangerRed = Color(0xFFEF4444);

  // Shadows
  static const Color shadowBlack = Color(0xFF1E1E1E);

  // Helper for Hex Color parsing
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
