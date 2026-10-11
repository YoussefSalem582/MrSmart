/// Spacing, radius and breakpoint tokens. No literal paddings in widgets.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;

  /// Content is centered and capped at this width on tablets.
  static const double maxContentWidth = 960;
  static const double tabletBreakpoint = 600;

  /// Minimum touch target (Material accessibility guidance).
  static const double minTouchTarget = 48;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
}
