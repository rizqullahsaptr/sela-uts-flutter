import 'package:flutter/material.dart';

/// Palet Sela: kertas krem hangat, teks arang, dan satu aksen hijau tua.
/// Semua warna dipilih agar kontras teks tetap di atas 4.5:1 pada latar terang.
abstract final class AppColors {
  static const background = Color(0xFFFAF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF23201C);
  static const inkMuted = Color(0xFF6B645C);
  static const primary = Color(0xFF1E4B3D);
  static const primaryPressed = Color(0xFF17392F);
  static const primarySoft = Color(0xFFE7EFE9);
  static const border = Color(0xFFE4DED2);
  static const borderStrong = Color(0xFFCFC6B6);
  static const imageFallback = Color(0xFFE9E3D6);
}

/// Skala jarak kelipatan 4 dengan kelipatan 8 untuk sebagian besar tata letak.
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

abstract final class AppRadius {
  static const double card = 14;
  static const double input = 12;
  static const double pill = 999;
}

/// Dua keluarga font: Newsreader untuk judul, Inter untuk teks antarmuka.
abstract final class AppText {
  static const display = 'Newsreader';
  static const body = 'Inter';

  static const title = TextStyle(
    fontFamily: display,
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.ink,
  );

  static const sectionTitle = TextStyle(
    fontFamily: display,
    fontSize: 23,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  static const cardTitle = TextStyle(
    fontFamily: body,
    fontSize: 17,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const bodyText = TextStyle(
    fontFamily: body,
    fontSize: 15,
    height: 1.55,
    color: AppColors.ink,
  );

  static const bodyMuted = TextStyle(
    fontFamily: body,
    fontSize: 14,
    height: 1.5,
    color: AppColors.inkMuted,
  );

  static const label = TextStyle(
    fontFamily: body,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const caption = TextStyle(
    fontFamily: body,
    fontSize: 12,
    height: 1.4,
    color: AppColors.inkMuted,
  );
}

ThemeData buildSelaTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        outlineVariant: AppColors.border,
      );

  return base.copyWith(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    textTheme: base.textTheme
        .apply(
          fontFamily: AppText.body,
          bodyColor: AppColors.ink,
          displayColor: AppColors.ink,
        )
        .copyWith(
          titleLarge: AppText.sectionTitle,
          bodyMedium: AppText.bodyText,
          bodySmall: AppText.bodyMuted,
          labelLarge: AppText.label,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppText.bodyMuted,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
        textStyle: AppText.label.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppText.label,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      shape: const StadiumBorder(),
      labelStyle: AppText.label,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
    ),
  );
}
