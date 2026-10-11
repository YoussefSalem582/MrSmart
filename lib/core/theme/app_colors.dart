import 'package:flutter/material.dart';

/// Single source of raw colors. Widgets read colors from [Theme] or
/// [AppSemanticColors], never from literals.
abstract final class AppColors {
  static const Color seed = Color(0xFF0F766E); // teal

  static const Color successLight = Color(0xFF15803D);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color warningLight = Color(0xFFB45309);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color dangerLight = Color(0xFFB91C1C);
  static const Color dangerDark = Color(0xFFF87171);
  static const Color simulatedLight = Color(0xFF6D28D9);
  static const Color simulatedDark = Color(0xFFC4B5FD);
}

/// Status colors that Material's [ColorScheme] does not cover.
@immutable
class AppSemanticColors {
  const AppSemanticColors({
    required this.success,
    required this.warning,
    required this.danger,
    required this.simulated,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color simulated;

  static const light = AppSemanticColors(
    success: AppColors.successLight,
    warning: AppColors.warningLight,
    danger: AppColors.dangerLight,
    simulated: AppColors.simulatedLight,
  );

  static const dark = AppSemanticColors(
    success: AppColors.successDark,
    warning: AppColors.warningDark,
    danger: AppColors.dangerDark,
    simulated: AppColors.simulatedDark,
  );

  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}
