import 'package:flutter/material.dart';

final ThemeData nexusTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF090C11),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF81CBBE),
    secondary: Color(0xFF88ACDC),
    surface: Color(0xFF121820),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.2,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.6,
    ),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFA4AFBE), height: 1.5),
    labelSmall: TextStyle(
      fontSize: 11,
      letterSpacing: 2.2,
      color: Color(0xFFA4AFBE),
    ),
  ),
  dividerColor: const Color(0xFF242C36),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFE5EBF2),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      side: const BorderSide(color: Color(0xFF303B48)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
);
