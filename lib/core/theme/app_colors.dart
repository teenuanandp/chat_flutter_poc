
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================
  // LIGHT THEME — AURORA
  // ==========================================

  // Brand
  static const Color primary = Color(0xFF009CA5);
  static const Color primaryForeground = Color(0xFFFFFFFF);
  static const Color primarySoft = Color(0xFFCDF4F6);

  static const Color secondary = Color(0xFF4AD496);
  static const Color secondaryForeground = Color(0xFF153B32);

  static const Color accent = Color(0xFF00B793);
  static const Color accentForeground = Color(0xFFFFFFFF);

  // Backgrounds and surfaces
  static const Color background = Color(0xFFFCFAF6);
  static const Color foreground = Color(0xFF08121D);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF9F7F1);
  static const Color surface3 = Color(0xFFF3F0E7);

  static const Color card = Color(0xFFFFFFFF);
  static const Color popover = Color(0xFFFFFFFF);

  // Text hierarchy
  static const Color textPrimary = Color(0xFF08121D);
  static const Color textSecondary = Color(0xFF555F69);
  static const Color textSubtle = Color(0xFF313C47);
  static const Color textTertiary = Color(0xFF77818C);

  // Muted
  static const Color muted = Color(0xFFF2F0EA);
  static const Color mutedForeground = Color(0xFF555F69);
  static const Color subtle = Color(0xFFEAE8E0);

  // Semantic colors
  static const Color success = Color(0xFF35C177);
  static const Color successForeground = Color(0xFFFFFFFF);

  static const Color warning = Color(0xFFF2AF48);
  static const Color warningForeground = Color(0xFF33240D);

  static const Color error = Color(0xFFE64343);
  static const Color errorForeground = Color(0xFFFFFFFF);

  static const Color info = Color(0xFF259ED6);
  static const Color infoForeground = Color(0xFFFFFFFF);

  // Borders and inputs
  static const Color border = Color(0xFFE0DED8);
  static const Color borderStrong = Color(0xFFC7C4BC);
  static const Color input = Color(0xFFEDEBE5);
  static const Color ring = Color(0x66009CA5);

  // Chat
  static const Color bubbleIn = Color(0xFFF4F2EC);
  static const Color bubbleInForeground = Color(0xFF08121D);

  static const Color bubbleOut = Color(0xFF009CA5);
  static const Color bubbleOutForeground = Color(0xFFFFFFFF);

  static const Color online = Color(0xFF00C470);
  static const Color mention = Color(0xFFF2AF48);

  static const Color badge = Color(0xFFE64343);
  static const Color badgeForeground = Color(0xFFFFFFFF);

  // ==========================================
  // DARK THEME — AURORA NIGHT
  // ==========================================

  static const Color darkBackground = Color(0xFF101A20);
  static const Color darkForeground = Color(0xFFF2F5F3);

  static const Color darkPrimary = Color(0xFF45C4C2);
  static const Color darkPrimaryForeground = Color(0xFF062D30);
  static const Color darkPrimarySoft = Color(0xFF193F42);

  static const Color darkSecondary = Color(0xFF70DDB0);
  static const Color darkSecondaryForeground = Color(0xFF10372B);

  static const Color darkAccent = Color(0xFF50D4B3);
  static const Color darkAccentForeground = Color(0xFF062D28);

  // Dark surfaces
  static const Color darkSurface = Color(0xFF17242A);
  static const Color darkSurface2 = Color(0xFF1D2D33);
  static const Color darkSurface3 = Color(0xFF26383E);

  static const Color darkCard = Color(0xFF17242A);
  static const Color darkPopover = Color(0xFF1D2D33);

  // Dark text
  static const Color darkTextPrimary = Color(0xFFF2F5F3);
  static const Color darkTextSecondary = Color(0xFFA8B6B8);
  static const Color darkTextSubtle = Color(0xFFD0D9D7);
  static const Color darkTextTertiary = Color(0xFF91A1A3);

  // Dark muted
  static const Color darkMuted = Color(0xFF26343A);
  static const Color darkMutedForeground = Color(0xFFA8B6B8);
  static const Color darkSubtle = Color(0xFF2D3B40);

  // Dark semantic colors
  static const Color darkSuccess = Color(0xFF62D99B);
  static const Color darkSuccessForeground = Color(0xFF082D1D);

  static const Color darkWarning = Color(0xFFF5C36B);
  static const Color darkWarningForeground = Color(0xFF35250B);

  static const Color darkError = Color(0xFFFF7770);
  static const Color darkErrorForeground = Color(0xFF3A1010);

  static const Color darkInfo = Color(0xFF71BDE8);
  static const Color darkInfoForeground = Color(0xFF102A3B);

  // Dark borders and inputs
  static const Color darkBorder = Color(0xFF33444A);
  static const Color darkBorderStrong = Color(0xFF4A5D62);
  static const Color darkInput = Color(0xFF26363C);
  static const Color darkRing = Color(0x9945C4C2);

  // Dark chat
  static const Color darkBubbleIn = Color(0xFF24343A);
  static const Color darkBubbleInForeground = Color(0xFFF2F5F3);

  static const Color darkBubbleOut = Color(0xFF087E80);
  static const Color darkBubbleOutForeground = Color(0xFFFFFFFF);

  static const Color darkOnline = Color(0xFF62D99B);
  static const Color darkMention = Color(0xFFF5C36B);

  static const Color darkBadge = Color(0xFFFF7770);
  static const Color darkBadgeForeground = Color(0xFF3A1010);

  // ==========================================
  // GRADIENTS
  // ==========================================

  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFF007D94),
      Color(0xFF009CA5),
      Color(0xFF4AD496),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF082C43),
      Color(0xFF0D5265),
      Color(0xFF008B78),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBrandGradient = LinearGradient(
    colors: [
      Color(0xFF164D59),
      Color(0xFF087E80),
      Color(0xFF45C4C2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==========================================
  // BORDER RADIUS
  // ==========================================

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2xl = 24;
  static const double radiusFull = 100;

  // ==========================================
  // SHADOWS
  // ==========================================

  static const List<BoxShadow> shadowXs = [
    BoxShadow(
      color: Color(0x0D08121D),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1008121D),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1408121D),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1F08121D),
      blurRadius: 50,
      offset: Offset(0, 20),
    ),
  ];
}
