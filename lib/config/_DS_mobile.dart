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
    // Display Large Bold
    double displayLarge = 56.0;
    // Display Small Bold
    double displaySmall = 48.0;

    // Heading 1 Bold
    double headingLarge = 48.0;
    // Heading 2 Bold
    double headingMedium = 40.0;
    // Heading 3 Bold
    double headingSmall = 32.0;

    // Heading 1
    double titleLarge = 48.0;
    // Heading 2
    double titleMedium = 40.0;
    // Heading 3
    double titleSmall = 32.0;

    // Subheading
    double displayMedium = 28.0;

    // Body 1 Regular Bold
    double labelLarge = 16.0;
    // Body 2 Regular Bold
    double labelMedium = 14.0;
    // Caption Regular Bold
    double labelSmall = 12.0;

    // Body 1 Regular
    double bodyLarge = 16.0;
    // Body 2 Regular
    double bodyMedium = 14.0;
    // Caption Regular
    double bodySmall = 12.0;

    // if ((Platform.isMacOS || Platform.isWindows || Platform.isLinux) == true) {
    //   displayLarge -= 5 - 0;
    //   displayMedium -= 5 - 0;
    //   displaySmall -= 5 - 0;
    //
    //   headingLarge -= 5 - 0;
    //   headingMedium -= 5 - 0;
    //   headingSmall -= 5 - 0;
    //
    //   titleLarge -= 5 - 0;
    //   titleMedium -= 5 - 0;
    //   titleSmall -= 5 - 0;
    //
    //   labelLarge -= 2 - 0;
    //   labelMedium -= 2 - 0;
    //   labelSmall -= 2 - 0;
    //
    //   bodyLarge -= 2 - 0;
    //   bodyMedium -= 2 - 0;
    //   bodySmall -= 2 - 0;
    // }

    this.displayLarge = displayLarge;
    this.displayMedium = displayMedium;
    this.displaySmall = displaySmall;

    this.headingLarge = headingLarge;
    this.headingMedium = headingMedium;
    this.headingSmall = headingSmall;

    this.titleLarge = titleLarge;
    this.titleMedium = titleMedium;
    this.titleSmall = titleSmall;

    this.labelLarge = labelLarge;
    this.labelMedium = labelMedium;
    this.labelSmall = labelSmall;

    this.bodyLarge = bodyLarge;
    this.bodyMedium = bodyMedium;
    this.bodySmall = bodySmall;
  }
}
