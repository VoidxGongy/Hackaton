import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color baldosa = Color(0xFFEAF1F3);
  static const Color papel = Color(0xFFFBFCFB);
  static const Color tinta = Color(0xFF0E1F3D);
  static const Color dotacion = Color(0xFF1C3FAA);
  static const Color precaucion = Color(0xFFFFCE1F);
  static const Color verde = Color(0xFF1F9D6B);
  static const Color rojo = Color(0xFFD9423A);
  static const Color linea = Color(0xFFC9D6DB);

  static const Color primary = dotacion;
  static const Color primarySoft = Color(0xFFE5EAF7);
  static const Color surface = baldosa;
  static const Color border = linea;
  static const Color textPrimary = tinta;
  static const Color textSecondary = Color(0xFF47566D);
  static const Color success = verde;
  static const Color successSoft = Color(0xFFE4F4ED);
  static const Color danger = rojo;
  static const Color dangerSoft = Color(0xFFFBE9E7);
  static const Color warning = precaucion;
  static const Color warningSoft = Color(0xFFFFF6CC);
  static const Color focus = dotacion;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 32;
}

class AppRadius {
  static const double s = 6;
  static const double m = 6;
  static const double l = 6;
  static const double xl = 20;
}

class AppTypography {
  static TextTheme apply(TextTheme base) => base.copyWith(
    displayLarge: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 64,
      height: 0.98,
      fontWeight: FontWeight.w800,
      color: AppColors.tinta,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    displayMedium: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 52,
      height: 1,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    displaySmall: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 42,
      height: 1.02,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    headlineLarge: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 36,
      height: 1.04,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
    ),
    headlineMedium: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 30,
      height: 1.08,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
    ),
    headlineSmall: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 26,
      height: 1.1,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
    ),
    titleLarge: const TextStyle(
      fontFamily: 'BigShouldersDisplay',
      fontSize: 24,
      height: 1.12,
      fontWeight: FontWeight.w700,
      color: AppColors.tinta,
    ),
    titleMedium: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 16,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: AppColors.tinta,
    ),
    titleSmall: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: AppColors.tinta,
    ),
    bodyLarge: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 16,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: AppColors.tinta,
    ),
    bodyMedium: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: AppColors.tinta,
    ),
    bodySmall: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 12,
      height: 1.35,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    labelLarge: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 14,
      height: 1.25,
      fontWeight: FontWeight.w600,
      color: AppColors.tinta,
    ),
    labelMedium: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 12,
      height: 1.25,
      fontWeight: FontWeight.w500,
      color: AppColors.tinta,
    ),
    labelSmall: const TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: 11,
      height: 1.25,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
  );
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color(0x140E1F3D),
    blurRadius: 2,
    offset: Offset(0, 1),
  );
}

class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 220);
  static const Curve curve = Curves.easeOutCubic;
}

class AppTheme {
  static ThemeData light() {
    GoogleFonts.config.allowRuntimeFetching = false;
    final base = ThemeData.light();

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        onPrimary: AppColors.papel,
        surface: AppColors.papel,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.baldosa,
      textTheme: AppTypography.apply(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.baldosa,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontFamily: 'BigShouldersDisplay',
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.papel,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.papel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.papel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.focus, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primarySoft,
        height: 76,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
