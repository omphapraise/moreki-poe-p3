import 'package:flutter/material.dart';

/// Moreki design tokens: OLED-black canvas, one bright accent per screen.
class AppColors {
  AppColors._();

  // Dark theme
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF101010);
  static const surface2 = Color(0xFF181818);
  static const darkBorder = Color(0xFF292929);
  static const hairline = Color(0xFF292929);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA6A6A6);
  static const textMuted = Color(0xFF808080);

  // Light theme (not styled for v2; dark is the shipped theme for now)
  static const lightBackground = Color(0xFFF6F7F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE3E5E8);
  static const lightTextPrimary = Color(0xFF14171A);
  static const lightTextSecondary = Color(0xFF5F6670);

  // Accents
  static const green = Color(0xFF32E875);
  static const cyan = Color(0xFF27D7E8);
  static const blue = Color(0xFF4678FF);
  static const violet = Color(0xFF9271FF);
  static const yellow = Color(0xFFFFD84D);
  static const orange = Color(0xFFFF9638);
  static const red = Color(0xFFFF514A);

  // Light-theme variants and older names kept so existing files still compile
  static const greenLight = Color(0xFF1D8A5A);
  static const redLight = Color(0xFFD64545);
  static const teal = Color(0xFF19C6A7);
  static const lime = Color(0xFFB6F23A);
  static const amber = Color(0xFFFFD84D);

  // Bento card
  static const cream = Color(0xFFF3F0E8);
  static const creamText = Color(0xFF101010);
  static const tileYellow = Color(0xFFFFD84D);
  static const tileGreen = Color(0xFF32E875);
  static const tileIndigo = Color(0xFF9271FF);
  static const tileOrange = Color(0xFFFF9638);
}