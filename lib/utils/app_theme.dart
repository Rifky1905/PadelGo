import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna khas PadelGo — brand identity pink dengan palet pendukung
/// yang nyaman dilihat dan kontras tinggi.
class PadelGoColors {
  PadelGoColors._();

  // Brand identity — vibrant pink / magenta
  static const Color primary = Color(0xFFE91E63);
  static const Color primaryDark = Color(0xFFC2185B);
  static const Color primarySoft = Color(0xFFFCE4EC);
  static const Color accent = Color(0xFFFF5C8A);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FA);
  static const Color card = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status indikator
  static const Color available = Color(0xFF2E9E62);
  static const Color availableBg = Color(0xFFE7F6EE);
  static const Color booked = Color(0xFF94A3B8);
  static const Color bookedBg = Color(0xFFF1F3F5);

  // Misc
  static const Color star = Color(0xFFFFB300);
  static const Color divider = Color(0xFFE9ECEF);

  // Warna gelap untuk banner CTA & aksen admin
  static const Color darkSurface = Color(0xFF111827);

  // Gradasi pink untuk banner promo
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFFFF6C9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: PadelGoColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PadelGoColors.primary,
        primary: PadelGoColors.primary,
        secondary: PadelGoColors.accent,
        surface: PadelGoColors.card,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: PadelGoColors.background,
        foregroundColor: PadelGoColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: PadelGoColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: PadelGoColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PadelGoColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PadelGoColors.primary,
          side: const BorderSide(color: PadelGoColors.primary, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: PadelGoColors.textHint, fontSize: 14),
        labelStyle: const TextStyle(color: PadelGoColors.textSecondary),
        prefixIconColor: PadelGoColors.textHint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PadelGoColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PadelGoColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: PadelGoColors.primary, width: 1.6),
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
        bodyColor: PadelGoColors.textPrimary,
        displayColor: PadelGoColors.textPrimary,
      ),
      dividerTheme: const DividerThemeData(
        color: PadelGoColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.white,
        selectedColor: PadelGoColors.primary,
        labelStyle: const TextStyle(color: PadelGoColors.textSecondary),
        side: const BorderSide(color: PadelGoColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: PadelGoColors.primary,
        unselectedItemColor: PadelGoColors.textHint,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
