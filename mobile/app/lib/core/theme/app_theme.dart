import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static const _background = Color(0xFFF7F6F3);
  static const _surface = Color(0xFFFFFFFF);
  static const _surfaceContainer = Color(0xFFF1F0EC);
  static const _surfaceContainerHigh = Color(0xFFE9E8E3);
  static const _outline = Color(0xFFEAEAEA);
  static const _outlineVariant = Color(0xFFF0EFEC);
  static const _ink = Color(0xFF111111);
  static const _muted = Color(0xFF787774);

  static ThemeData get light {
    const colors = ColorScheme.light(
      primary: _ink,
      onPrimary: Colors.white,
      surface: _surface,
      onSurface: _ink,
      onSurfaceVariant: _muted,
      outline: _outline,
      outlineVariant: _outlineVariant,
      surfaceContainer: _surfaceContainer,
      surfaceContainerHigh: _surfaceContainerHigh,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      scrim: Color(0xFF111111),
    );
    final textTheme = _textTheme.apply(
      bodyColor: _ink,
      displayColor: _ink,
      fontFamily: 'BeVietnamPro',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'BeVietnamPro',
      scaffoldBackgroundColor: _background,
      colorScheme: colors,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.light,
        AppSpacing(),
        AppRadius(),
        AppShadows.light,
        AppMotion(),
      ],
      dividerColor: _outlineVariant,
      splashFactory: NoSplash.splashFactory,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _background,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: 'BeVietnamPro',
          color: _ink,
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.light.faint),
        border: _inputBorder(_outline),
        enabledBorder: _inputBorder(_outline),
        focusedBorder: _inputBorder(_ink, width: 1.4),
        errorBorder: _inputBorder(AppColors.light.danger),
        focusedErrorBorder: _inputBorder(AppColors.light.danger, width: 1.4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: _surface,
        modalBarrierColor: Color(0x52111111),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );

  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 46,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.38,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 32,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.96,
    ),
    headlineLarge: TextStyle(
      fontSize: 30,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.75,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.w500,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      fontSize: 12.5,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      fontSize: 13.5,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
  );
}
