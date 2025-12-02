import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const Color primaryColor = Color(0xFFFFB74D); // Warm orange
  const Color secondaryColor = Color(0xFFFFCC80); // Soft lighter orange
  const Color accentColor = Color(0xFF5D4037); // Deep brown for contrast
  const Color backgroundColor = Color(0xFFFFF8E1); // Light cream
  const Color textColor = Color(0xFF3E2723); // Dark brown

  final TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: textColor,
    ),
  );

  return ThemeData(
    useMaterial3: true,

    // MAIN COLORS
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      tertiary: accentColor,
    ),

    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,

    // TEXT STYLES
    textTheme: textTheme,

    // BUTTONS
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: primaryColor, width: 2),
        foregroundColor: primaryColor,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    // TEXTFIELDS
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(
        color: Colors.black45,
        fontSize: 14,
      ),
    ),

    // CARDS
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
