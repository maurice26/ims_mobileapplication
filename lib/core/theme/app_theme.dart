import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme_tokens.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFAFAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: ThemeTokens.purple,
      brightness: Brightness.light,
      primary: ThemeTokens.purple,
      secondary: ThemeTokens.emerald,
      surface: Colors.white,
      error: const Color(0xFFEF4444),
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: ThemeTokens.ink,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ThemeTokens.ink,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: ThemeTokens.ink,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: ThemeTokens.ink,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.ink,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.ink,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.ink,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ThemeTokens.ink,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ThemeTokens.muted,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.ink,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: ThemeTokens.muted,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ThemeTokens.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: ThemeTokens.purple.withValues(alpha: 0.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: ThemeTokens.purple, width: 2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ThemeTokens.purple,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ThemeTokens.ink,
      elevation: 2,
      shadowColor: Color(0x1F000000),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: ThemeTokens.ink,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ThemeTokens.purple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      labelStyle: const TextStyle(
        color: ThemeTokens.muted,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFFCBD5E1),
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: ThemeTokens.purple,
      suffixIconColor: ThemeTokens.muted,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      color: Colors.white,
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: ThemeTokens.ink,
        fontSize: 14,
      ),
      dataTextStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: ThemeTokens.ink,
        fontSize: 14,
      ),
      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1E5FF)),
      dividerThickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ThemeTokens.ink,
      contentTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      // Avoid SnackBarBehavior.floating on web where it can render off-screen.
      behavior: SnackBarBehavior.fixed,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      surfaceTintColor: Colors.white,
    ),
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: const Color(0xFFF1E5FF),
      selectedColor: ThemeTokens.purple,
      labelStyle: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    ),
  );

  // Keep original dark theme as fallback
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0B1E),
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9D4EDD),
      secondary: Color(0xFFC77DFF),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9D4EDD),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
}
