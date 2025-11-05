import 'DS.dart';

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

    double displayLarge = 38.0;
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

    this.displayLarge = displayLarge + 2.5;
    this.displayMedium = displayMedium + 2.5;
    this.displaySmall = displaySmall + 2.5;

    this.headingLarge = headingLarge + 2.5;
    this.headingMedium = headingMedium + 2.5;
    this.headingSmall = headingSmall + 2.5;

    this.titleLarge = titleLarge + 2.5;
    this.titleMedium = titleMedium + 2.5;
    this.titleSmall = titleSmall + 2.5;

    this.labelLarge = labelLarge + 2.5;
    this.labelMedium = labelMedium + 2.5;
    this.labelSmall = labelSmall + 2.5;

    this.bodyLarge = bodyLarge + 2.5;
    this.bodyMedium = bodyMedium + 2.5;
    this.bodySmall = bodySmall + 2.5;
  }
}
