import 'package:flutter/material.dart';

class AppTheme {
  // Paleta moderna — verde comercio, superficies claras
  static const Color primary = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF047857);
  static const Color onPrimary = Colors.white;
  static const Color surface = Color(0xFFF1F5F9);
  static const Color surfaceCard = Colors.white;
  static const Color onSurface = Color(0xFF0F172A);
  static const Color onSurfaceMuted = Color(0xFF64748B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFD97706);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color primaryTint = Color(0xFFECFDF5);

  static const double fontBody = 15;
  static const double fontLabel = 15;
  static const double fontTitle = 17;
  static const double fontHeadline = 20;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double minAccessibleTouch = 44;
  static const double minTouchTarget = 48;

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      secondary: primaryDark,
      onSecondary: onPrimary,
      surface: surfaceCard,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceMuted,
      outline: cardBorder,
      primaryContainer: primaryTint,
      onPrimaryContainer: primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          fontSize: fontBody,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(fontSize: fontBody, color: onSurface),
        bodyMedium: TextStyle(fontSize: 13, color: onSurfaceMuted),
        labelLarge: TextStyle(
          fontSize: fontBody,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surfaceCard,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: onSurface, size: 22),
        titleTextStyle: TextStyle(
          fontSize: fontHeadline,
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: -0.3,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceMuted,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: cardBorder,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(64, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 2,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceCard,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: warning),
        ),
        labelStyle: const TextStyle(
          fontSize: fontLabel,
          fontWeight: FontWeight.w500,
          color: onSurfaceMuted,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        hintStyle: const TextStyle(fontSize: fontBody, color: onSurfaceMuted),
        helperStyle: const TextStyle(fontSize: 12, color: onSurfaceMuted),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: warning,
          fontWeight: FontWeight.w500,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: cardBorder),
          minimumSize: const Size(64, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: const TextStyle(
            fontSize: fontBody,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: surfaceCard,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: primaryTint,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: onSurfaceMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: onSurfaceMuted,
          );
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        titleTextStyle: const TextStyle(
          fontSize: fontTitle,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: onSurface,
        contentTextStyle: const TextStyle(fontSize: fontBody, color: onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(color: cardBorder, thickness: 1),
    );
  }
}
