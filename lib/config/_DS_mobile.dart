import 'dart:io' show Platform;

import 'DS.dart' show AppBreakpoints;

class TextSize {
  /// Display Large
  late final double displayLarge;
  late final double displayMedium;
  late final double displaySmall;

  /// Headline
  late final double headingLarge;
  late final double headingMedium;
  late final double headingSmall;

  /// Title
  late final double titleLarge;
  late final double titleMedium;
  late final double titleSmall;

  /// Label
  late final double labelLarge;
  late final double labelMedium;
  late final double labelSmall;

  /// Body
  late final double bodyLarge;
  late final double bodyMedium;
  late final double bodySmall;

  TextSize({double fontSizeIndex = 0}) {
    bool isDesktop = AppBreakpoints.isDesktop || AppBreakpoints.isLargeDesktop;

    double displayLarge = 40.0;
    double displayMedium = 36.0;
    double displaySmall = 32.0;

    double headingLarge = 28.0;
    double headingMedium = 24.0;
    double headingSmall = 20.0;

    double titleLarge = 28.0;
    double titleMedium = 24.0;
    double titleSmall = 20.0;

    double labelLarge = 16.0;
    double labelMedium = 14.0;
    double labelSmall = 12.0;

    double bodyLarge = 16.0;
    double bodyMedium = 14.0;
    double bodySmall = 12.0;

    if ((Platform.isMacOS || Platform.isWindows || Platform.isLinux) == true) {
      displayLarge -= 5;
      displayMedium -= 5;
      displaySmall -= 5;

      headingLarge -= 5;
      headingMedium -= 5;
      headingSmall -= 5;

      titleLarge -= 5;
      titleMedium -= 5;
      titleSmall -= 5;

      labelLarge -= 2;
      labelMedium -= 2;
      labelSmall -= 2;

      bodyLarge -= 2;
      bodyMedium -= 2;
      bodySmall -= 2;
    }

    this.displayLarge = displayLarge + 1;
    this.displayMedium = displayMedium + 1;
    this.displaySmall = displaySmall + 1;

    this.headingLarge = headingLarge + 1;
    this.headingMedium = headingMedium + 1;
    this.headingSmall = headingSmall + 1;

    this.titleLarge = titleLarge + 1;
    this.titleMedium = titleMedium + 1;
    this.titleSmall = titleSmall + 1;

    this.labelLarge = labelLarge + 1;
    this.labelMedium = labelMedium + 1;
    this.labelSmall = labelSmall + 1;

    this.bodyLarge = bodyLarge + 1;
    this.bodyMedium = bodyMedium + 1;
    this.bodySmall = bodySmall + 1;
  }
}
