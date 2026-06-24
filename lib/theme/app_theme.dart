import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_local_store.dart';

class AppTheme {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static const String _themePreferenceKey = 'preferred_theme_mode';

  static const Color _seed = Color(0xff13EC5B);
  static const Color _lightBackground = Color(0xffF2EDE9);
  static const Color _lightSurface = Colors.white;
  static const Color _darkBackground = Color(0xFF141A16);
  static const Color _darkSurface = Color(0xFF1B221E);

  static void setDarkMode(bool enabled) {
    themeModeNotifier.value = enabled ? ThemeMode.dark : ThemeMode.light;
    unawaited(_saveThemeMode(themeModeNotifier.value));
  }

  static Future<void> initialize() async {
    final savedMode = await AppLocalStore.readString(_themePreferenceKey);
    themeModeNotifier.value =
        _themeModeFromString(savedMode) ?? ThemeMode.system;
  }

  static TextTheme _textTheme(Brightness brightness) {
    final base = GoogleFonts.interTextTheme();
    final color = brightness == Brightness.dark
        ? const Color(0xFFF2F5F3)
        : Colors.black87;

    return base.apply(bodyColor: color, displayColor: color);
  }

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
      surface: _lightSurface,
    );

    return _buildTheme(
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBackground,
      appBarBackground: _lightBackground,
      appBarForeground: Colors.black87,
      textTheme: _textTheme(Brightness.light),
      cardColor: _lightSurface,
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      surface: _darkSurface,
    );

    return _buildTheme(
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkBackground,
      appBarBackground: _darkBackground,
      appBarForeground: const Color(0xFFF2F5F3),
      textTheme: _textTheme(Brightness.dark),
      cardColor: _darkSurface,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color appBarBackground,
    required Color appBarForeground,
    required TextTheme textTheme,
    required Color cardColor,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        centerTitle: true,
      ),
      canvasColor: colorScheme.surface,
      iconTheme: IconThemeData(color: colorScheme.primary),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        disabledColor: colorScheme.surface.withValues(alpha: 0.6),
        labelStyle: textTheme.labelLarge ?? const TextStyle(),
        secondaryLabelStyle: textTheme.labelLarge ?? const TextStyle(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  static Future<void> _saveThemeMode(ThemeMode mode) async {
    await AppLocalStore.writeString(_themePreferenceKey, _themeModeToString(mode));
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode? _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }
}
