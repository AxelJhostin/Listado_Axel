import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0D5C2E);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF1A6B3C);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE65100);
  static const Color cardBorder = Color(0xFFBDBDBD);

  static const double fontBody = 18;
  static const double fontLabel = 20;
  static const double fontTitle = 22;
  static const double fontHeadline = 26;
  static const double minAccessibleTouch = 48;
  static const double minTouchTarget = 56;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        surface: surface,
        onSurface: onSurface,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: surface,
      textTheme: TextTheme(
        headlineMedium: const TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
        titleLarge: const TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: const TextStyle(fontSize: fontBody, color: onSurface),
        labelLarge: const TextStyle(
          fontSize: fontBody,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: onPrimary,
        titleTextStyle: TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.bold,
          color: onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(minTouchTarget),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        extendedSizeConstraints: BoxConstraints(minHeight: 64, minWidth: 64),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(
          fontSize: fontLabel,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: fontLabel,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
        hintStyle: TextStyle(
          fontSize: fontBody,
          color: onSurface.withValues(alpha: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(minAccessibleTouch, minAccessibleTouch),
          textStyle: const TextStyle(fontSize: fontBody),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(minTouchTarget),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.bold,
          color: onSurface,
        ),
      ),
    );
  }
}
