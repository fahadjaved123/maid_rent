import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MaidMatch Design System
/// Based on Material Design 3 with Trust Blue primary
class AppTheme {
  // ────────────────────────────────────────────────────────
  // COLOR PALETTE - Material Design 3 System
  // ────────────────────────────────────────────────────────

  // Primary - Trust Blue (for all users)
  static const Color primary = Color(0xFF004AC6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimaryContainer = Color(0xFFEEEFFF);

  // Secondary
  static const Color secondary = Color(0xFF495C95);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFACBFFF);
  static const Color onSecondaryContainer = Color(0xFF394C84);

  // Tertiary (for accents and highlights)
  static const Color tertiary = Color(0xFF943700);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFBC4800);
  static const Color onTertiaryContainer = Color(0xFFFFEDE6);

  // User Segment Colors
  static const Color serviceTeal = Color(0xFF0D9488); // For Maid experience
  static const Color managementIndigo = Color(0xFF3730A3); // For Household experience

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Success (for status indicators)
  static const Color success = Color(0xFF16A34A); // Green-600
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccessContainer = Color(0xFF14532D);

  // Warning (for pending states)
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF78350F);

  // Surface colors
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceDim = Color(0xFFD8DADC);
  static const Color surfaceBright = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F6);
  static const Color surfaceContainer = Color(0xFFECEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E5);
  static const Color surfaceVariant = Color(0xFFE0E3E5);

  // Text colors
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF434655);

  // Outline
  static const Color outline = Color(0xFF737686);
  static const Color outlineVariant = Color(0xFFC3C6D7);

  // Inverse colors
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inverseOnSurface = Color(0xFFEFF1F3);
  static const Color inversePrimary = Color(0xFFB4C5FF);

  // Status Badge Colors
  static const Color hourlyBadgeBg = Color(0xFFDBE1FF);
  static const Color hourlyBadgeText = Color(0xFF00174B);
  static const Color contractBadgeBg = Color(0xFFE0E7FF);
  static const Color contractBadgeText = Color(0xFF3730A3);

  // Rating Color
  static const Color ratingGold = Color(0xFFBC4800);

  // Verified Badge
  static const Color verifiedBlue = Color(0xFF004AC6);

  // Legacy aliases for backward compatibility
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color accentColor = tertiary;
  static const Color errorColor = error;
  static const Color warningColor = warning;
  static const Color successColor = success;
  static const Color backgroundColor = surface;
  static const Color cardColor = surfaceContainerLowest;
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color dividerColor = outlineVariant;

  // ────────────────────────────────────────────────────────
  // SPACING SYSTEM - 4px baseline grid
  // ────────────────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double gutterMobile = 16.0;
  static const double gutterDesktop = 64.0;

  // ────────────────────────────────────────────────────────
  // BORDER RADIUS - Soft Roundedness
  // ────────────────────────────────────────────────────────
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // ────────────────────────────────────────────────────────
  // ELEVATION - Ambient Shadows
  // ────────────────────────────────────────────────────────
  static List<BoxShadow> get shadowLevel1 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLevel2 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 30,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowLevel3 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 50,
          offset: const Offset(0, 20),
        ),
      ];

  // ────────────────────────────────────────────────────────
  // TYPOGRAPHY - Inter Font System
  // ────────────────────────────────────────────────────────

  // Display Large (48px, 700, -0.02em)
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 56 / 48,
        letterSpacing: -0.02 * 48,
        color: onSurface,
      );

  // Headline Large (32px, 600, -0.01em) - Desktop
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
        letterSpacing: -0.01 * 32,
        color: onSurface,
      );

  // Headline Large Mobile (24px, 600)
  static TextStyle get headlineLargeMobile => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: onSurface,
      );

  // Headline Medium (24px, 600)
  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: onSurface,
      );

  // Body Large (18px, 400)
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: onSurface,
      );

  // Body Medium (16px, 400)
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: onSurface,
      );

  // Body Small (14px, 400)
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurface,
      );

  // Label Large (15px, 600)
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 20 / 15,
        color: onSurface,
      );

  // Label Medium (14px, 500, 0.01em)
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.01 * 14,
        color: onSurface,
      );

  // Label Small (12px, 600)
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        color: onSurface,
      );

  // ────────────────────────────────────────────────────────
  // THEME DATA
  // ────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
      ),
      scaffoldBackgroundColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceContainerLowest,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          color: onSurfaceVariant,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceContainerLowest,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryContainer.withOpacity(0.1),
        labelStyle: GoogleFonts.inter(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
