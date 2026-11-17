import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ==========================================
  // LIGHT THEME
  // ==========================================

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,
      secondary: AppColors.secondary,
      background: AppColors.background,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surface2,
      foreground: AppColors.textPrimary,
      mutedForeground: AppColors.mutedForeground,
      border: AppColors.border,
      error: AppColors.error,
    );
  }

  // ==========================================
  // DARK THEME
  // ==========================================

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkPrimaryForeground,
      secondary: AppColors.darkSecondary,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurface2,
      foreground: AppColors.darkTextPrimary,
      mutedForeground: AppColors.darkMutedForeground,
      border: AppColors.darkBorder,
      error: AppColors.darkError,
    );
  }

  // ==========================================
  // MESSAGE STATUS COLORS
  // ==========================================
  // Light Theme
  static Color get sentTickColor => const Color.fromARGB(255, 115, 250, 184);

  static Color get deliveredTickColor => const Color.fromARGB(255, 74, 122, 64);

  static Color get readTickColor => const Color.fromARGB(255, 37, 43, 40);

  static Color get pendingTickColor => const Color.fromARGB(255, 127, 127, 127);

  // Dark Theme
  static Color get darkSentTickColor => const Color.fromARGB(255, 12, 247, 134);

  static Color get darkDeliveredTickColor => const Color.fromARGB(255, 27, 119, 6);

  static Color get darkReadTickColor => const Color.fromARGB(255, 1, 20, 10);

  static Color get darkPendingTickColor => const Color.fromARGB(255, 29, 49, 35);

  // ==========================================
  // COMMON THEME BUILDER
  // ==========================================

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color foreground,
    required Color mutedForeground,
    required Color border,
    required Color error,
  }) {
    // Flutter's standard colour system.
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: onPrimary,
          secondary: secondary,
          onSecondary: brightness == Brightness.light
              ? AppColors.secondaryForeground
              : AppColors.darkSecondaryForeground,
          surface: surface,
          onSurface: foreground,
          error: error,
          onError: brightness == Brightness.light
              ? AppColors.errorForeground
              : AppColors.darkErrorForeground,
          outline: border,
          surfaceContainerHighest: surfaceVariant,
        );

    // Typography.
    final textTheme = const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16),
      bodyMedium: TextStyle(fontSize: 14),
      bodySmall: TextStyle(fontSize: 12),
    ).apply(bodyColor: foreground, displayColor: foreground);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      scaffoldBackgroundColor: background,
      textTheme: textTheme,

      // App bar.
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),

      // Cards.
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
          side: BorderSide(color: border),
        ),
      ),

      // Buttons.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusMd),
          ),
        ),
      ),

      // Input fields.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),

      // Dividers.
      dividerTheme: DividerThemeData(color: border, thickness: 1),

      // Icons.
      iconTheme: IconThemeData(color: mutedForeground),

      // Loading indicators.
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),

      // Snackbars.
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: TextStyle(color: foreground),
      ),
    );
  }
}
