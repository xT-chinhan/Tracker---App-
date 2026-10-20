import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.faint,
    required this.income,
    required this.expense,
    required this.warning,
    required this.warningContainer,
    required this.warningBar,
    required this.danger,
    required this.dangerContainer,
    required this.dangerBar,
    required this.successContainer,
    required this.viz,
  });

  static const light = AppColors(
    faint: Color(0xFFA9A8A3),
    income: Color(0xFF1F8A4C),
    expense: Color(0xFF111111),
    warning: Color(0xFF956400),
    warningContainer: Color(0xFFFBF3DB),
    warningBar: Color(0xFFD99A1E),
    danger: Color(0xFFB3261E),
    dangerContainer: Color(0xFFFDEBEC),
    dangerBar: Color(0xFFD9483B),
    successContainer: Color(0xFFEDF3EC),
    viz: <Color>[
      Color(0xFF2A78D6),
      Color(0xFFEB6834),
      Color(0xFF1BAF7A),
      Color(0xFFEDA100),
      Color(0xFFE87BA4),
    ],
  );

  final Color faint;
  final Color income;
  final Color expense;
  final Color warning;
  final Color warningContainer;
  final Color warningBar;
  final Color danger;
  final Color dangerContainer;
  final Color dangerBar;
  final Color successContainer;
  final List<Color> viz;

  @override
  AppColors copyWith({
    Color? faint,
    Color? income,
    Color? expense,
    Color? warning,
    Color? warningContainer,
    Color? warningBar,
    Color? danger,
    Color? dangerContainer,
    Color? dangerBar,
    Color? successContainer,
    List<Color>? viz,
  }) => AppColors(
    faint: faint ?? this.faint,
    income: income ?? this.income,
    expense: expense ?? this.expense,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    warningBar: warningBar ?? this.warningBar,
    danger: danger ?? this.danger,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    dangerBar: dangerBar ?? this.dangerBar,
    successContainer: successContainer ?? this.successContainer,
    viz: viz ?? this.viz,
  );

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      faint: Color.lerp(faint, other.faint, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      warningBar: Color.lerp(warningBar, other.warningBar, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      dangerBar: Color.lerp(dangerBar, other.dangerBar, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      viz: List<Color>.generate(
        viz.length,
        (index) => Color.lerp(viz[index], other.viz[index], t)!,
      ),
    );
  }
}

@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    this.s1 = 4,
    this.s2 = 8,
    this.s3 = 12,
    this.s4 = 16,
    this.s5 = 20,
    this.s6 = 24,
    this.s8 = 32,
    this.s10 = 40,
    this.screenPadding = 20,
  });

  final double s1;
  final double s2;
  final double s3;
  final double s4;
  final double s5;
  final double s6;
  final double s8;
  final double s10;
  final double screenPadding;

  @override
  AppSpacing copyWith({double? screenPadding}) =>
      AppSpacing(screenPadding: screenPadding ?? this.screenPadding);

  @override
  AppSpacing lerp(covariant AppSpacing? other, double t) => this;
}

@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  const AppRadius({
    this.xs = 8,
    this.sm = 12,
    this.md = 14,
    this.lg = 18,
    this.xl = 28,
    this.pill = 999,
  });

  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double pill;

  @override
  AppRadius copyWith() => this;

  @override
  AppRadius lerp(covariant AppRadius? other, double t) => this;
}

@immutable
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.card,
    required this.sheet,
    required this.raised,
  });

  static const light = AppShadows(
    card: <BoxShadow>[
      BoxShadow(color: Color(0x08111111), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x09111111), offset: Offset(0, 6), blurRadius: 20),
    ],
    sheet: <BoxShadow>[
      BoxShadow(
        color: Color(0x14111111),
        offset: Offset(0, -8),
        blurRadius: 32,
      ),
    ],
    raised: <BoxShadow>[
      BoxShadow(color: Color(0x2E111111), offset: Offset(0, 6), blurRadius: 16),
    ],
  );

  final List<BoxShadow> card;
  final List<BoxShadow> sheet;
  final List<BoxShadow> raised;

  @override
  AppShadows copyWith() => this;

  @override
  AppShadows lerp(covariant AppShadows? other, double t) => this;
}

@immutable
class AppMotion extends ThemeExtension<AppMotion> {
  const AppMotion({
    this.press = const Duration(milliseconds: 160),
    this.fast = const Duration(milliseconds: 200),
    this.sheet = const Duration(milliseconds: 360),
  });

  final Duration press;
  final Duration fast;
  final Duration sheet;

  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);
  static const Curve drawer = Cubic(0.32, 0.72, 0, 1);

  @override
  AppMotion copyWith() => this;

  @override
  AppMotion lerp(covariant AppMotion? other, double t) => this;
}

extension ThuChiTheme on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  AppSpacing get spacing => Theme.of(this).extension<AppSpacing>()!;
  AppRadius get radius => Theme.of(this).extension<AppRadius>()!;
  AppShadows get shadows => Theme.of(this).extension<AppShadows>()!;
  AppMotion get motion => Theme.of(this).extension<AppMotion>()!;
}
