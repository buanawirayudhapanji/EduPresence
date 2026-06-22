import 'package:flutter/material.dart';

class AppTheme {
  // Educational Premium Light Mode Palette (Indigo & Teal)
  static const Color primary = Color(0xFF4F46E5); // Royal Indigo - friendly & trustworthy
  static const Color primaryLight = Color(0xFF6366F1); // Lighter Indigo
  static const Color secondary = Color(0xFF0D9488); // Calm Teal - peaceful & educational
  static const Color accent = Color(0xFFEC4899); // Soft Rose Accent
  static const Color success = Color(0xFF10B981); // Emerald Green (Present / In-Radius)
  static const Color warning = Color(0xFFF59E0B); // Amber Orange (Late / Warning)
  static const Color danger = Color(0xFFEF4444); // Coral Red (Absent / Out-of-Radius)
  static const Color background = Color(0xFFF8FAFC); // Soft Slate Off-White Background
  static const Color surface = Color(0xFFFFFFFF); // Clean White for cards & surfaces
  static const Color textPrimary = Color(0xFF1E293B); // Muted Dark Slate for highly readable text
  static const Color textSecondary = Color(0xFF64748B); // Slate Muted Text
  static const Color border = Color(0xFFE2E8F0); // Very Soft Slate Border

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: danger,
        background: background,
        surface: surface,
        onBackground: textPrimary,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -0.1),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
      ),
    );
  }

  // Gradients for modern CTA buttons, card headers, and overlays
  static Gradient get primaryGradient => const LinearGradient(
        colors: [primary, Color(0xFF6366F1)], // Indigo-600 to Indigo-500 gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient get accentGradient => const LinearGradient(
        colors: [primaryLight, primary], // Indigo gradient
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static Gradient get successGradient => const LinearGradient(
        colors: [Color(0xFF059669), success],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Soft premium card shadow for Light Mode
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04), // Very soft shadow for clean light mode
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
}
