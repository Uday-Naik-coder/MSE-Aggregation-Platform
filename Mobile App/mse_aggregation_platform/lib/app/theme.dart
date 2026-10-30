import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Colour tokens ──────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Brand
  static const primary      = Color(0xFF1A73E8);  // Google-blue, professional
  static const primaryDark  = Color(0xFF0D47A1);
  static const secondary    = Color(0xFF00897B);  // Teal accent
  static const secondaryDark = Color(0xFF00695C);

  // Status
  static const success  = Color(0xFF2E7D32);
  static const warning  = Color(0xFFF57C00);
  static const error    = Color(0xFFC62828);
  static const info     = Color(0xFF0277BD);

  // Status chip fills
  static const pendingBg   = Color(0xFFFFF8E1);
  static const pendingFg   = Color(0xFFF57C00);
  static const approvedBg  = Color(0xFFE8F5E9);
  static const approvedFg  = Color(0xFF2E7D32);
  static const rejectedBg  = Color(0xFFFFEBEE);
  static const rejectedFg  = Color(0xFFC62828);
  static const completedBg = Color(0xFFE3F2FD);
  static const completedFg = Color(0xFF1565C0);
  static const openBg      = Color(0xFFE8F5E9);
  static const openFg      = Color(0xFF2E7D32);

  // Surfaces – Light
  static const backgroundLight = Color(0xFFF5F7FA);
  static const surfaceLight     = Color(0xFFFFFFFF);
  static const cardLight        = Color(0xFFFFFFFF);

  // Surfaces – Dark
  static const backgroundDark = Color(0xFF0F1117);
  static const surfaceDark    = Color(0xFF1C1F26);
  static const cardDark       = Color(0xFF252A34);

  // Text
  static const textPrimary   = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted     = Color(0xFF9CA3AF);

  // Star rating
  static const starFilled = Color(0xFFFACC15);
  static const starEmpty  = Color(0xFFE5E7EB);
}

// ─── Spacing ────────────────────────────────────────────────────────────────
class AppSpacing {
  AppSpacing._();
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

// ─── Radius ─────────────────────────────────────────────────────────────────
class AppRadius {
  AppRadius._();
  static const sm  = BorderRadius.all(Radius.circular(8));
  static const md  = BorderRadius.all(Radius.circular(12));
  static const lg  = BorderRadius.all(Radius.circular(16));
  static const xl  = BorderRadius.all(Radius.circular(24));
  static const full = BorderRadius.all(Radius.circular(100));
}

// ─── Theme builder ──────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(ColorScheme cs) {
    final base = GoogleFonts.interTextTheme().apply(
      bodyColor: cs.onSurface,
      displayColor: cs.onSurface,
    );
    return base.copyWith(
      displayLarge:  base.displayLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1.5),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium:base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      titleLarge:    base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium:   base.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      labelLarge:    base.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
    );
  }

  static ThemeData get light {
    const cs = ColorScheme(
      brightness:   Brightness.light,
      primary:      AppColors.primary,
      onPrimary:    Colors.white,
      secondary:    AppColors.secondary,
      onSecondary:  Colors.white,
      error:        AppColors.error,
      onError:      Colors.white,
      surface:      AppColors.surfaceLight,
      onSurface:    AppColors.textPrimary,
    );
    return _buildTheme(cs);
  }

  static ThemeData get dark {
    const cs = ColorScheme(
      brightness:   Brightness.dark,
      primary:      Color(0xFF82B1FF),
      onPrimary:    Color(0xFF003180),
      secondary:    Color(0xFF80CBC4),
      onSecondary:  Color(0xFF00251A),
      error:        Color(0xFFEF9A9A),
      onError:      Color(0xFF690005),
      surface:      AppColors.surfaceDark,
      onSurface:    Color(0xFFE8EAED),
    );
    return _buildTheme(cs);
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    final tt = _buildTextTheme(cs);
    return ThemeData(
      useMaterial3:  true,
      colorScheme:   cs,
      textTheme:     tt,
      scaffoldBackgroundColor: cs.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: cs.brightness == Brightness.light
            ? AppColors.surfaceLight
            : AppColors.surfaceDark,
        foregroundColor: cs.onSurface,
        titleTextStyle: tt.titleLarge?.copyWith(color: cs.onSurface),
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.brightness == Brightness.light ? AppColors.cardLight : AppColors.cardDark,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        margin: EdgeInsets.zero,
        shadowColor: Colors.black12,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          textStyle: tt.labelLarge?.copyWith(fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          side: BorderSide(color: cs.primary, width: 1.5),
          textStyle: tt.labelLarge?.copyWith(fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: tt.labelLarge,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.brightness == Brightness.light
            ? const Color(0xFFF1F3F9) : const Color(0xFF2A2D38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: cs.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.md,
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        labelStyle: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
        hintStyle:  tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.4)),
      ),

      dividerTheme: DividerThemeData(
        color: cs.onSurface.withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.full),
        side: BorderSide.none,
        labelStyle: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.brightness == Brightness.light ? AppColors.surfaceLight : AppColors.surfaceDark,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withValues(alpha: 0.5),
        selectedLabelStyle: tt.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: tt.labelSmall,
        elevation: 8,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
        backgroundColor: cs.brightness == Brightness.light ? AppColors.textPrimary : AppColors.cardDark,
        contentTextStyle: tt.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}
