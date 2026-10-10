import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean spatial tokens adhering to 8pt spatial grid
class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Material Design 3 High-Contrast & Accessible Color System
/// STRICTLY COMPLIANT WITH RAILOCITY DESIGN GUIDELINES:
/// - Warm ivory surfaces & deep charcoal text
/// - Restrained railway-inspired Forest Green / Dark Olive accent
/// - Muted amber for warnings & carefully chosen red for critical disruptions
/// - No dominant blue brand colors, no tacky gradients or glassmorphism
class AppColors {
  // Warm Light Theme Surfaces & Backgrounds
  static const Color backgroundLight = Color(0xFFFAF7F2); // Warm ivory
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowLight = Color(0xFFF4EFE6);
  static const Color surfaceContainerLight = Color(0xFFEDE7DC);
  static const Color surfaceContainerHighLight = Color(0xFFE4DC CE);
  static const Color borderLight = Color(0xFFDDD4C5);
  static const Color borderHighlightLight = Color(0xFFC7BCAB);

  // Warm Slate Dark Theme Surfaces & Backgrounds (for dark mode toggle)
  static const Color backgroundDark = Color(0xFF141715);
  static const Color surfaceDark = Color(0xFF1C201E);
  static const Color surfaceContainerLowDark = Color(0xFF222724);
  static const Color surfaceContainerDark = Color(0xFF2B312D);
  static const Color surfaceContainerHighDark = Color(0xFF353C37);
  static const Color borderDark = Color(0xFF3A423D);
  static const Color borderHighlightDark = Color(0xFF4C5650);

  // Primary Brand Accent: Restrained Railway Forest Green / Dark Olive
  static const Color primary = Color(0xFF1B4D3E); // Railway Forest Green
  static const Color primaryLight = Color(0xFF2B6B57);
  static const Color primaryDark = Color(0xFF103328);
  static const Color primaryContainerLight = Color(0xFFE3EFE9);
  static const Color onPrimaryContainerLight = Color(0xFF0D2E24);
  static const Color primaryContainerDark = Color(0xFF16382C);
  static const Color onPrimaryContainerDark = Color(0xFFD4E8DF);

  // Secondary Accent: Earth Olive / Brass Railway Tones
  static const Color secondary = Color(0xFF3A5A40); // Earth Olive
  static const Color secondaryLight = Color(0xFF588157);
  static const Color secondaryContainerLight = Color(0xFFE8EFE5);
  static const Color onSecondaryContainerLight = Color(0xFF1F3523);
  static const Color secondaryContainerDark = Color(0xFF253B29);
  static const Color onSecondaryContainerDark = Color(0xFFDEEBDA);

  // Warning & Alert Colors: Muted Amber
  static const Color warning = Color(0xFFD97706); // Muted Amber
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningContainerLight = Color(0xFFFEF3C7);
  static const Color onWarningContainerLight = Color(0xFF78350F);
  static const Color warningContainerDark = Color(0xFF452203);
  static const Color onWarningContainerDark = Color(0xFFFDE68A);

  // Critical Disruption Colors: Carefully Chosen Red
  static const Color criticalRed = Color(0xFFDC2626); // Crimson Red
  static const Color criticalRedDark = Color(0xFFB91C1C);
  static const Color criticalRedContainerLight = Color(0xFFFEE2E2);
  static const Color onCriticalRedContainerLight = Color(0xFF7F1D1D);
  static const Color criticalRedContainerDark = Color(0xFF4A1010);
  static const Color onCriticalRedContainerDark = Color(0xFFFECACA);

  // Success / On-Time Colors
  static const Color success = Color(0xFF15803D); // Railway On-Time Green
  static const Color successContainerLight = Color(0xFFDCFCE7);
  static const Color onSuccessContainerLight = Color(0xFF14532D);
  static const Color successContainerDark = Color(0xFF11381E);
  static const Color onSuccessContainerDark = Color(0xFFBBF7D0);

  // High-Contrast Deep Charcoal Typography
  static const Color textPrimaryLight = Color(0xFF191C1B); // Deep Charcoal
  static const Color textSecondaryLight = Color(0xFF4A524D); // Medium Charcoal
  static const Color textMutedLight = Color(0xFF6F7973); // Muted Charcoal

  static const Color textPrimaryDark = Color(0xFFF4F7F4); // Off-White
  static const Color textSecondaryDark = Color(0xFFC4CCC6); // Muted Sage
  static const Color textMutedDark = Color(0xFF8B968E); // Dark Muted
}

class AppTheme {
  /// Builds Google Sans / Plus Jakarta Sans typography theme hierarchy
  static TextTheme _buildTextTheme(bool isDark, double textScaleFactor) {
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;

    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontSize: 36 * textScaleFactor,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: textPrimary,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontSize: 28 * textScaleFactor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontSize: 24 * textScaleFactor,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontSize: 22 * textScaleFactor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontSize: 19 * textScaleFactor,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontSize: 17 * textScaleFactor,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontSize: 16 * textScaleFactor,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: textPrimary,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontSize: 14 * textScaleFactor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontSize: 12 * textScaleFactor,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontSize: 14 * textScaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: textPrimary,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontSize: 13 * textScaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        color: textSecondary,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontSize: 11 * textScaleFactor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: textMuted,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontSize: 13 * textScaleFactor,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: textPrimary,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontSize: 11 * textScaleFactor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: textSecondary,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontSize: 10 * textScaleFactor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: textMuted,
      ),
    );
  }

  /// Warm Ivory & Forest Green Light Theme (Primary default)
  static ThemeData lightTheme({double textScale = 1.0, bool highContrast = false}) {
    final textTheme = _buildTextTheme(false, textScale);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainerLight,
        onPrimaryContainer: AppColors.onPrimaryContainerLight,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainerLight,
        onSecondaryContainer: AppColors.onSecondaryContainerLight,
        tertiary: AppColors.warning,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.warningContainerLight,
        onTertiaryContainer: AppColors.onWarningContainerLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerLow: AppColors.surfaceContainerLowLight,
        surfaceContainer: AppColors.surfaceContainerLight,
        surfaceContainerHigh: AppColors.surfaceContainerHighLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: highContrast ? AppColors.textPrimaryLight : AppColors.borderHighlightLight,
        outlineVariant: AppColors.borderLight,
        error: AppColors.criticalRed,
        onError: Colors.white,
        errorContainer: AppColors.criticalRedContainerLight,
        onErrorContainer: AppColors.onCriticalRedContainerLight,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: highContrast ? AppColors.textPrimaryLight : AppColors.borderLight,
            width: highContrast ? 1.5 : 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(88, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: highContrast ? AppColors.textPrimaryLight : AppColors.primary,
            width: 1.2,
          ),
          minimumSize: const Size(88, 46),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimaryLight,
          fontSize: 17 * textScale,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight, size: 22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainerLight,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 11 * textScale,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textMutedLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? AppColors.primary : AppColors.textMutedLight,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMutedLight,
          fontSize: 13 * textScale,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondaryLight,
          fontSize: 13 * textScale,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.criticalRed, width: 1.2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Warm Slate Dark Theme
  static ThemeData darkTheme({double textScale = 1.0, bool highContrast = false}) {
    final textTheme = _buildTextTheme(true, textScale);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryLight,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        secondary: AppColors.secondaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryContainerDark,
        onSecondaryContainer: AppColors.onSecondaryContainerDark,
        tertiary: AppColors.warning,
        onTertiary: Colors.black,
        tertiaryContainer: AppColors.warningContainerDark,
        onTertiaryContainer: AppColors.onWarningContainerDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerLow: AppColors.surfaceContainerLowDark,
        surfaceContainer: AppColors.surfaceContainerDark,
        surfaceContainerHigh: AppColors.surfaceContainerHighDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        outline: highContrast ? AppColors.textPrimaryDark : AppColors.borderHighlightDark,
        outlineVariant: AppColors.borderDark,
        error: AppColors.criticalRed,
        onError: Colors.white,
        errorContainer: AppColors.criticalRedContainerDark,
        onErrorContainer: AppColors.onCriticalRedContainerDark,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: highContrast ? AppColors.textPrimaryDark : AppColors.borderDark,
            width: highContrast ? 1.5 : 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(88, 46),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: BorderSide(
            color: highContrast ? AppColors.textPrimaryDark : AppColors.borderHighlightDark,
            width: 1.2,
          ),
          minimumSize: const Size(88, 46),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13 * textScale,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textPrimaryDark,
          fontSize: 17 * textScale,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 22),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryContainerDark,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return GoogleFonts.plusJakartaSans(
            fontSize: 11 * textScale,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primaryLight : AppColors.textMutedDark,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: isSelected ? AppColors.primaryLight : AppColors.textMutedDark,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowDark,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textMutedDark,
          fontSize: 13 * textScale,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.textSecondaryDark,
          fontSize: 13 * textScale,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.criticalRed, width: 1.2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
