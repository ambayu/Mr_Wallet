import 'package:flutter/material.dart';

class AppColors {
  // Pastel Themes
  static const Color butterYellow = Color(0xFFFFF0B3);
  static const Color butterYellowDark = Color(0xFFFFDE59);
  static const Color mintGreen = Color(0xFFBFF2A5);
  static const Color mintGreenDark = Color(0xFF88D968);
  static const Color bubblePink = Color(0xFFFFBEE3);
  static const Color bubblePinkDark = Color(0xFFFF7BBF);
  static const Color lavenderPurple = Color(0xFFA594F9);
  static const Color skyBlue = Color(0xFFC4D7FF);
  static const Color coralOrange = Color(0xFFFF7A59);
  static const Color softPeach = Color(0xFFFFD6A5);

  // Neutral & Brutalist
  static const Color bgOffWhite = Color(0xFFF9F9FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderBlack = Color(0xFF191919);
  static const Color textBlack = Color(0xFF191919);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color pillGray = Color(0xFFF3F4F6);

  // Shadow
  static const Color shadowBlack = Color(0xFF191919);

  // Helper for Hex Color parsing
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
