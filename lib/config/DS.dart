// ignore_for_file: file_names, unused_field, constant_identifier_names

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:sizer/sizer.dart';

import '_DS.dart';

WidgetStateProperty<Color> primaryButtonColor = WidgetStateProperty.resolveWith(
  (states) {
    if (states.contains(WidgetState.pressed)) {
      return AppColors.primary.shade500;
    }
    return AppColors.primary.shade500;
  },
);

WidgetStateProperty<Color> primaryButtonTextColor = WidgetStateProperty.resolveWith(
  (states) {
    if (states.contains(WidgetState.pressed)) {
      return AppColors.whiteSwatch;
    }
    return AppColors.whiteSwatch;
  },
);

/// ———————————————
/// Astro Status System Colors (Dark Theme fills)
/// ———————————————
///
class AppStatusColors {
  static const Color critical = Color(0xFFFF2A04); // urgent, alert
  static const Color serious = Color(0xFFFFAF3D); // error, needs attention
  static const Color caution = Color(0xFFFAD800); // warning, watch
  static const Color normal = Color(0xFF00A200); // ok, go
  static const Color standby = Color(0xFF64D9FF); // available
  static const Color off = Color(0xFF7B8089); // disabled

  static const Color criticalBorder = Color(0xFF661102);
  static const Color seriousBorder = Color(0xFF664618);
  static const Color cautionBorder = Color(0xFF645600);
  static const Color normalBorder = Color(0xFF005A00);
  static const Color standbyBorder = Color(0xFF285766);
  static const Color offBorder = Color(0xFF3C3E42);
  static const Color criticalText = Colors.white;
  static const Color seriousText = Colors.white;
  static const Color cautionText = Colors.black;
  static const Color normalText = Colors.black;
  static const Color standbyText = Colors.black;
  static const Color offText = Colors.white;
}

/// Convenience – picks black text on light bg, white on dark bg.
Color idealTextColor(Color bg) => bg.computeLuminance() > 0.35 ? Colors.grey.shade900 : Colors.white;

const double mobileCTAHeight = 38;
const double tabletAndAboveCTAHeight = 42;

class AppBreakpoints {
  static const double mobile = 480; // smartphones « classiques » + grands smartphones
  static const double tablet = 900; // grands écrans (tablettes, petits laptops/tablettes hybrides)
  static const double desktop = 1440; // desktop / écran grand utilisateur
  static const double largeDesktop = double.infinity;

  static double _w(BuildContext context) => MediaQuery.of(context).size.width;

  static bool isMobile2(BuildContext context) => _w(context) <= mobile;

  static bool isTablet2(BuildContext context) {
    final w = _w(context);
    return w > mobile && w <= tablet;
  }

  static bool isDesktop2(BuildContext context) {
    final w = _w(context);
    return w > tablet && w <= desktop;
  }

  static bool isLargeDesktop2(BuildContext context) => _w(context) > desktop;

  static final bool isMobile = 100.w <= mobile;
  static final bool isTablet = 100.w <= tablet && 100.w > mobile;
  static final bool isDesktop = 100.w <= desktop && 100.w > tablet;
  static final bool isLargeDesktop = 100.w > desktop;
}

class AppSpacing {
  final BuildContext context;

  AppSpacing({required this.context});

  static const double tinyTinyMargin = 2.0;
  static const double tinyMargin = 4.0;
  static const double elementMargin = 8.0;
  static const double groupMargin = 16.0;
  static const double textFieldMargin = 16;
  static const double containerInsideMarginSmall = 12;
  static const double containerInsideMargin = 24;
  static const double sectionMargin = 40.0;
  static const double pageMargin = 16.0;
  static const double buttonHorizontalPadding = 12.0;
  static const double buttonVerticalPadding = 8.0;

  static const SizedBox tinyTinyMarginBox = SizedBox.square(dimension: tinyTinyMargin);
  static const SizedBox tinyMarginBox = SizedBox.square(dimension: tinyMargin);
  static const SizedBox elementMarginBox = SizedBox.square(dimension: elementMargin);
  static const SizedBox groupMarginBox = SizedBox.square(dimension: groupMargin);
  static const SizedBox textFieldMarginBox = SizedBox.square(dimension: textFieldMargin);
  static const SizedBox containerInsideMarginSmallBox = SizedBox.square(dimension: containerInsideMarginSmall);
  static const SizedBox containerInsideMarginBox = SizedBox.square(dimension: containerInsideMargin);
  static const SizedBox sectionMarginBox = SizedBox.square(dimension: sectionMargin);
  static const SizedBox pageMarginBox = SizedBox.square(dimension: pageMargin);
}

class AppRadius {
  // tinyTiny
  static const double tinyTinyRadius = 4;
  static const BorderRadius tinyTiny = BorderRadius.all(Radius.circular(tinyTinyRadius));
  static const double tinyRadius = 8;
  static const BorderRadius tiny = BorderRadius.all(Radius.circular(tinyRadius));
  static const double smallRadius = 12;
  static const BorderRadius small = BorderRadius.all(Radius.circular(smallRadius));
  static const double mediumRadius = 16;
  static const BorderRadius medium = BorderRadius.all(Radius.circular(mediumRadius));
  static const BorderRadius borderRadius18 = BorderRadius.all(Radius.circular(18));
  static const double radius18 = 18;

  static const double radius20 = 20;
  static const BorderRadius borderRadius20 = BorderRadius.all(Radius.circular(radius20));
  static const double largeRadius = 24;
  static const BorderRadius large = BorderRadius.all(Radius.circular(largeRadius));
  static const double radius28 = 28;
  static const BorderRadius borderRadius28 = BorderRadius.all(Radius.circular(radius28));
  static const double radius30 = 30;
  static const BorderRadius borderRadius30 = BorderRadius.all(Radius.circular(radius30));
  static const double extraLargeRadius = 64;
  static const BorderRadius extraLarge = BorderRadius.all(Radius.circular(extraLargeRadius));
}

/// Murya – Foundations → Colors
class AppButtonColors {
  // Primary
  static const Color primaryTextDefault = Color(0xFFFFFFFF);
  static const Color primarySurfaceDefault = Color(0xFF6F3FF5);
  static const Color primaryBorderDefault = Color(0xFF1F1633);
  static const Color primaryShadowDefault = Color(0xFF4B22B5);

  static const Color primarySurfaceHover = Color(0xFF825AF7);
  static const Color primarySurfacePressed = Color(0xFF6F3FF5);

  static const Color primaryTextDisabled = Color(0xFFA0A0A0);
  static const Color primarySurfaceDisabled = Color(0xFFB8B8B8);

  // Secondary
  static const Color secondaryTextDefault = Color(0xFF1F1633);
  static const Color secondarySurfaceDefault = Color(0xFFF4F3EC);
  static const Color secondaryBorderDefault = Color(0xFFD8D5D1);
  static const Color secondaryShadowDefault = Color(0xFFD8D5D1);

  static const Color secondarySurfaceHover = Color(0xFFF4F6FF);
  static const Color secondarySurfacePressed = Color(0xFFF4F3EC);
  static const Color secondaryBorderFocus = Color(0x572B7FFF);

  static const Color secondaryTextDisabled = Color(0xFFA3A3A3);
  static const Color secondarySurfaceDisabled = Color(0xFFF5F5F5);
  static const Color secondaryBorderDisabled = Color(0xFFC0C0C0);

  // Tertiary
  static const Color tertiaryTextDefault = Color(0xFF5E5873);
  static const Color tertiarySurfaceDefault = Color(0x00FFFFFF);

  static const Color tertiaryTextHover = Color(0xFF1F1633);
  static const Color tertiarySurfaceHover = Color(0xFFE5E3D7);

  static const Color tertiaryTextPressed = Color(0xFF1F1633);
  static const Color tertiarySurfacePressed = Color(0xFFD4D4D4);

  static const Color tertiaryTextDisabled = Color(0xFFA0A0A0);
  static const Color tertiarySurfaceDisabled = Color(0x00FFFFFF);

  // Destructive
  static const Color destructiveSurfaceDefault = Color(0xFFFB2C36);
  static const Color destructiveSurfaceHover = Color(0xFFFF6B73);
  static const Color destructiveShadowHover = Color(0xFF1F1633);

  static const Color destructiveTextDisabled = Color(0xFFFFB3B3);
  static const Color destructiveSurfaceDisabled = Color(0xFFFFE5E5);
  static const Color destructiveBorderDisabled = Color(0xFFFFB3B3);
}

class AppColors {
  static Color backgroundColor = const Color(0XFFF4F3EC);

  // ================== Primitive tokens ==================

  // Text
  static const Color textPrimary = Color(0xFF0D0D0D);
  static const Color textSecondary = Color(0xFF4D4D4D);
  static const Color textTertiary = Color(0xFF7A7A7A);
  static const Color textInverted = Color(0xFFFFFFFF);

  // Brand / Primary
  static const Color primaryDefault = Color(0xFF0D0D0D);
  static const Color primaryHover = Color(0xFF6F3FF5);
  static const Color primaryFocus = Color(0xFF6F3FF5);
  static const Color primaryPressed = Color(0xFF5B2FDB);
  static const Color primaryDisabled = Color(0xFFB8B8B8); // from spec tile

  // Secondary / Neutral surfaces
  static const Color secondaryDisabled = Color(0xFFF9F8F7);
  static const Color secondaryDefault = Color(0xFFF4F1ED);
  static const Color secondaryHover = Color(0xFFE5E1DC);
  static const Color secondaryFocus = Color(0xFFE5E1DC);
  static const Color secondaryPressed = Color(0xFFDAD6D1);

  // Success (Green)
  static const Color successDefault = Color(0xFF00A870);
  static const Color successHover = Color(0xFF00905F);
  static const Color successText = Color(0xFF004C33);

  // Error (Red)
  static const Color errorDefault = Color(0xFFFF3B30);
  static const Color errorHover = Color(0xFFE63228);
  static const Color errorText = Color(0xFF5C0000);

  // Warning (Amber)
  static const Color warningDefault = Color(0xFFFEC84B);
  static const Color warningHover = Color(0xFFE5B340);
  static const Color warningText = Color(0xFF5A3F00);

  // Border
  static const Color borderLight = Color(0xFFE5E1DC);
  static const Color borderMedium = Color(0xFFC6C1BB);
  static const Color borderDark = Color(0xFF0D0D0D);

  // Background
  static const Color backgroundSurface = Color(0xFFFFFFFF);
  static const Color backgroundDefault = Color(0xFFF4F3EC);
  static const Color backgroundHover = Color(0xFFF1EEEB);
  static const Color backgroundInverted = Color(0xFF0D0D0D);
  static const Color backgroundCard = Color(0xFFEDECE4);

  // Tags
  // rgba(111, 63, 245, 0.2)
  static const Color tagSoftSkill = Color.fromRGBO(111, 63, 245, 0.2);

  // rgba(91, 47, 219, 1)
  static const Color tagSoftSkillText = Color.fromRGBO(91, 47, 219, 1);

  // rgba(58, 176, 194, 0.15)
  static const Color tagHardSkill = Color.fromRGBO(58, 176, 194, 0.15);

  // rgba(35, 116, 128, 1)
  static const Color tagHardSkillText = Color.fromRGBO(35, 116, 128, 1);

  // rgba(0, 168, 112, 0.15)
  static const Color tagBeginnerLevel = Color.fromRGBO(0, 168, 112, 0.15);

  // rgba(0, 76, 51, 1)
  static const Color tagBeginnerLevelText = Color.fromRGBO(0, 76, 51, 1);

  // rgba(245, 163, 63, 0.2)
  static const Color tagIntermediateLevel = Color.fromRGBO(245, 163, 63, 0.2);

  // rgba(199, 128, 40, 1)
  static const Color tagIntermediateLevelText = Color.fromRGBO(199, 128, 40, 1);

  // rgba(255, 59, 48, 0.15)
  static const Color tagAdvancedLevel = Color.fromRGBO(255, 59, 48, 0.15);

  // rgba(92, 0, 0, 1)
  static const Color tagAdvancedLevelText = Color.fromRGBO(92, 0, 0, 1);

  // rgba(13, 13, 13, 0.15)
  static const Color tagExpertLevel = Color.fromRGBO(199, 40, 128, 0.2);

  // rgba(13, 13, 13, 1)
  static const Color tagExpertLevelText = Color.fromRGBO(13, 13, 13, 1);

  // Gradient sample (for convenience)
  static const List<Color> gradient = <Color>[
    Color(0xFF5F27CD),
    Color(0xFF9159E5),
    Color(0xFFC26BFF),
    Color(0xFFFF4100),
    Color(0xFF49B86C),
    Color(0xFF05E7D2),
    Color(0xFF8CD9E5),
    Color(0xFF3ED20D),
  ];

  // ================== Material swatches ==================

  /// Brand purple swatch (uses hover as 500 and pressed as 700).
  static final MaterialColor primary = _swatchFromBase(primaryDefault);
  static final MaterialColor secondary = _swatchFromBase(secondaryDefault);

  /// Success/Green swatch from provided anchors.
  static final MaterialColor green = _swatchFromBase(successDefault);

  /// Error/Red swatch from provided anchors.
  static final MaterialColor error = _swatchFromBase(errorDefault);

  /// Warning/Amber swatch from provided anchors.
  static final MaterialColor amber = _swatchFromBase(warningDefault);

  /// Neutral/Gray swatch around the secondary/default family.
  static final MaterialColor neutral = _swatchFromBase(secondaryDefault);

  // A convenience black/white swatch for theming APIs that expect MaterialColor
  static final MaterialColor blackSwatch = _swatchFromBase(textPrimary);
  static final MaterialColor whiteSwatch = _swatchFromBase(textInverted);

  // ================== Helper ==================

  /// Create a MaterialColor from a base color. Any [overrides] provided
  /// (e.g., {500: base}) are used verbatim; missing keys are generated.
  static MaterialColor _swatchFromBase(
    Color base, {
    Map<int, Color>? overrides,
  }) {
    final r = base.red, g = base.green, b = base.blue;

    Color blendTo(Color other, double t) => Color.fromARGB(
          0xFF,
          (r + (other.red - r) * t).round(),
          (g + (other.green - g) * t).round(),
          (b + (other.blue - b) * t).round(),
        );

    final generated = <int, Color>{
      50: blendTo(Colors.white, .92),
      100: blendTo(Colors.white, .84),
      200: blendTo(Colors.white, .72),
      300: blendTo(Colors.white, .62),
      400: blendTo(Colors.white, .45),
      500: base,
      600: blendTo(Colors.black, .12),
      700: blendTo(Colors.black, .24),
      800: blendTo(Colors.black, .36),
      900: blendTo(Colors.black, .54),
    };

    if (overrides != null) {
      generated.addAll(overrides);
    }

    return MaterialColor(base.value, generated);
  }
}

class AppElevatedButtonStyle {
  static WidgetStateProperty<Color> foregroundColor = WidgetStateProperty.resolveWith<Color>((states) {
    if (states.contains(WidgetState.disabled)) {
      return AppButtonColors.secondaryTextDefault;
    }
    return AppButtonColors.primaryTextDefault;
  });

  static WidgetStateProperty<Color> backgroundColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      if (states.contains(WidgetState.disabled)) {
        return AppButtonColors.primarySurfaceDisabled;
      }
      if (states.contains(WidgetState.pressed)) {
        return AppButtonColors.primarySurfacePressed;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppButtonColors.primarySurfaceHover;
      }
      return AppButtonColors.primarySurfaceDefault;
    },
  );

  static WidgetStateProperty<Color> overlayColor = WidgetStateProperty.all(Colors.transparent);

  static WidgetStateProperty<Color> shadowColor = WidgetStateProperty.all(AppButtonColors.primaryShadowDefault);

  static WidgetStateProperty<Color> surfaceTintColor = WidgetStateProperty.all(Colors.transparent);

  static WidgetStateProperty<BorderSide> side = WidgetStateProperty.resolveWith((states) {
    return const BorderSide(
      color: AppButtonColors.primaryBorderDefault,
      width: 1,
    );
  });

  static WidgetStateProperty<TextStyle?>? textStyle;
  static WidgetStateProperty<double> elevation = WidgetStateProperty.all<double>(4);
  static WidgetStateProperty<EdgeInsetsGeometry> padding = WidgetStateProperty.all<EdgeInsetsGeometry>(
    const EdgeInsets.symmetric(
      horizontal: AppSpacing.buttonHorizontalPadding * 1.5,
      vertical: AppSpacing.buttonVerticalPadding * .5,
    ),
  );
  static WidgetStateProperty<Size>? minimumSize;

  static WidgetStateProperty<Size>? fixedSize =
      WidgetStateProperty.resolveWith<Size>((states) => const Size.fromHeight(mobileCTAHeight));

  static WidgetStateProperty<Size>? maximumSize;

  static WidgetStateProperty<Color> iconColor = WidgetStateProperty.resolveWith((states) {
    return AppColors.whiteSwatch;
  });
  static WidgetStateProperty<double> iconSize = WidgetStateProperty.all<double>(16);
  static WidgetStateProperty<OutlinedBorder> shape = WidgetStateProperty.all<OutlinedBorder>(
    const RoundedRectangleBorder(borderRadius: AppRadius.small),
  );
  static WidgetStateProperty<MouseCursor> mouseCursor = WidgetStateProperty.all<MouseCursor>(SystemMouseCursors.click);
  static VisualDensity? visualDensity = VisualDensity.compact;
  static MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.shrinkWrap;
  static Duration animationDuration = const Duration(milliseconds: 100);
  static bool enableFeedback = true;
  static AlignmentGeometry alignment = Alignment.center;
  static InteractiveInkFeatureFactory splashFactory = InkRipple.splashFactory;

  static ElevatedButtonThemeData buildTheme(ThemeData themeData, BuildContext context) {
    final TextSize textSize = TextSize();
    final isMobile = DeviceHelper.isMobile(context);
    return ElevatedButtonThemeData(
      style: themeData.elevatedButtonTheme.style?.copyWith(
        fixedSize: isMobile
            ? WidgetStateProperty.all<Size>(
                const Size.fromHeight(mobileCTAHeight),
              )
            : WidgetStateProperty.all<Size>(
                const Size.fromHeight(tabletAndAboveCTAHeight),
              ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontalPadding * 1.5,
            vertical: AppSpacing.buttonVerticalPadding * .5,
          ),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          themeData.textTheme.bodyMedium!.copyWith(
            color: AppColors.backgroundColor,
            fontSize: textSize.bodyMedium,
            fontWeight: isMobile ? FontWeight.w600 : null,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class AppTextButtonStyle {
  static WidgetStateProperty<Color> foregroundColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      if (states.contains(WidgetState.disabled)) {
        return AppColors.secondary.shade400;
      }
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade500;
      }
      if (states.contains(WidgetState.focused)) {
        return AppColors.primary.shade500;
      }
      return AppColors.primary.shade500;
    },
  );

  static WidgetStateProperty<Color> backgroundColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade50;
      }
      if (states.contains(WidgetState.focused)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    },
  );

  static WidgetStateProperty<Color> overlayColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade50;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade200;
      }
      if (states.contains(WidgetState.focused)) {
        return AppColors.whiteSwatch;
      }
      return Colors.transparent;
    },
  );

  static WidgetStateProperty<Color> shadowColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade500;
      }
      if (states.contains(WidgetState.disabled)) {
        return AppColors.primary.shade50;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade100;
      }
      if (states.contains(WidgetState.focused)) {
        return AppColors.primary.shade600;
      }
      return AppColors.primaryDefault;
    },
  );

  static WidgetStateProperty<Color> surfaceTintColor = WidgetStateProperty.resolveWith<Color>(
    (states) {
      return Colors.transparent;
    },
  );

  static WidgetStateProperty<BorderSide> side = WidgetStateProperty.resolveWith((states) {
    return BorderSide(
      color: AppColors.primary,
      width: .5,
    );
  });

  static WidgetStateProperty<TextStyle?>? textStyle;
  static WidgetStateProperty<double> elevation = WidgetStateProperty.resolveWith<double>((states) {
    if (states.contains(WidgetState.pressed)) {
      return 4;
    }
    return 0;
  });
  static WidgetStateProperty<EdgeInsetsGeometry> padding = WidgetStateProperty.all<EdgeInsetsGeometry>(
    const EdgeInsets.symmetric(
      horizontal: AppSpacing.buttonHorizontalPadding,
      vertical: AppSpacing.buttonVerticalPadding,
    ),
  );
  static WidgetStateProperty<Size> minimumSize = WidgetStateProperty.all<Size>(const Size(50, 50));
  static WidgetStateProperty<Size>? fixedSize;
  static WidgetStateProperty<Size> maximumSize = WidgetStateProperty.all<Size>(const Size(480, 56));
  static WidgetStateProperty<Color> iconColor = foregroundColor;
  static WidgetStateProperty<double> iconSize = WidgetStateProperty.all<double>(16);
  static WidgetStateProperty<OutlinedBorder> shape = WidgetStateProperty.resolveWith<OutlinedBorder>((states) {
    if (states.contains(WidgetState.pressed)) {
      return const RoundedRectangleBorder(borderRadius: AppRadius.large);
    }
    return RoundedRectangleBorder(
      borderRadius: AppRadius.large,
      side: BorderSide(
        color: AppColors.secondary.shade700,
        width: 1,
      ),
    );
  });
  static WidgetStateProperty<MouseCursor> mouseCursor = WidgetStateProperty.all<MouseCursor>(SystemMouseCursors.click);

  static VisualDensity? visualDensity = VisualDensity.compact;
  static MaterialTapTargetSize tapTargetSize = MaterialTapTargetSize.shrinkWrap;
  static Duration animationDuration = const Duration(milliseconds: 100);
  static bool enableFeedback = true;
  static AlignmentGeometry alignment = Alignment.center;
  static InteractiveInkFeatureFactory splashFactory = InkRipple.splashFactory;

  static TextButtonThemeData buildTheme(ThemeData themeData, BuildContext context) {
    return TextButtonThemeData(
      style: themeData.textButtonTheme.style?.copyWith(
        fixedSize: WidgetStateProperty.resolveWith<Size?>(
          (states) {
            if (100.w <= AppBreakpoints.mobile) {
              return const Size.fromHeight(mobileCTAHeight);
            }
            return const Size.fromHeight(AppBreakpoints.tablet);
          },
        ),
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 12.5, vertical: 15),
        ),
        textStyle: WidgetStateProperty.all<TextStyle>(
          themeData.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            decorationColor: AppColors.secondary.shade700,
            decorationThickness: 0,
            decorationStyle: TextDecorationStyle.solid,
            overflow: TextOverflow.ellipsis,
            // letterSpacing: .025 * bodyMedium,
          ),
        ),
      ),
    );
  }
}

class AppDropdownMenuThemeData {
  static const InputBorder baseInputBorder = OutlineInputBorder(
    borderRadius: AppRadius.small,
    borderSide: BorderSide.none,
  );

  static const TextStyle? textStyle = null;

  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    fillColor: Colors.transparent,
    focusColor: AppColors.primary.shade500,
    hoverColor: AppColors.primary.shade400,
    iconColor: null,
    prefixIconColor: null,
    suffixIconColor: null,
    labelStyle: null,
    floatingLabelStyle: null,
    helperStyle: null,
    helperMaxLines: null,
    hintStyle: null,
    errorStyle: null,
    errorMaxLines: null,
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    floatingLabelAlignment: FloatingLabelAlignment.start,
    isDense: true,
    isCollapsed: false,
    prefixStyle: null,
    suffixStyle: null,
    counterStyle: null,
    filled: true,
    activeIndicatorBorder: null,
    outlineBorder: BorderSide.none,
    errorBorder: baseInputBorder,
    focusedBorder: baseInputBorder,
    focusedErrorBorder: baseInputBorder,
    disabledBorder: baseInputBorder,
    enabledBorder: baseInputBorder,
    border: baseInputBorder,
    alignLabelWithHint: false,
    contentPadding: const EdgeInsets.only(
      left: AppSpacing.elementMargin + AppSpacing.tinyMargin,
      right: AppSpacing.elementMargin + AppSpacing.tinyMargin,
      top: 0,
      bottom: 0,
    ),
    constraints: const BoxConstraints(
      minHeight: mobileCTAHeight,
      minWidth: 0,
      maxHeight: mobileCTAHeight,
      maxWidth: 173 * 2,
    ),
  );

  static MenuStyle menuStyle = MenuStyle(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade500;
      }
      return AppColors.primary.shade300;
    }),
    shadowColor: null,
    surfaceTintColor: null,
    elevation: null,
    padding: null,
    minimumSize: WidgetStateProperty.all<Size>(
      const Size.fromHeight(10),
    ),
    fixedSize: null,
    maximumSize: WidgetStateProperty.all<Size>(
      const Size.fromHeight(200),
    ),
    side: null,
    shape: null,
    mouseCursor: null,
    visualDensity: VisualDensity.compact,
    alignment: Alignment.centerLeft,
  );

  static DropdownMenuThemeData buildTheme(ThemeData themeData, BuildContext context) {
    final isMobile = DeviceHelper.isMobile(context);
    return themeData.dropdownMenuTheme
      ..inputDecorationTheme!.copyWith(
        constraints: BoxConstraints(
          minHeight: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          minWidth: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) * 3,
          maxHeight: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          maxWidth: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) * 6,
        ),
        labelStyle: themeData.textTheme.bodyMedium?.copyWith(
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w600,
        ),
      );
  }
}

class AppButtonThemeData {
  static const ButtonTextTheme textTheme = ButtonTextTheme.accent;
  static const double minWidth = 10.0;
  static const double height = 16.0;
  static const EdgeInsetsGeometry padding = EdgeInsets.zero;
  static const ShapeBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(AppRadius.smallRadius),
    ),
  );
  static const ButtonBarLayoutBehavior layoutBehavior = ButtonBarLayoutBehavior.padded;
  static const bool alignedDropdown = true;
  static Color? buttonColor = AppColors.primary.shade500;
  static Color? disabledColor = AppColors.primary.shade100;
  static Color? focusColor = AppColors.primary.shade400;
  static Color? hoverColor = AppColors.primary.shade300;
  static Color? highlightColor = AppColors.primary.shade500;
  static Color? splashColor = AppColors.primary.shade500;
  static ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    onPrimary: AppColors.secondary,
    primary: AppColors.secondary.shade700,
    primaryContainer: AppColors.primary,
    onPrimaryContainer: AppColors.secondary,
    onSecondary: AppColors.secondary,
    secondary: AppColors.primary,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.secondary,
    tertiary: AppColors.secondary,
    onTertiary: AppColors.secondary,
    tertiaryContainer: AppColors.secondary,
    onTertiaryContainer: AppColors.secondary,
    error: AppColors.errorDefault,
    onError: AppColors.secondary,
    errorContainer: AppColors.errorDefault,
    onErrorContainer: AppColors.secondary,
    surface: AppColors.secondary,
    onSurface: AppColors.primaryDefault,
    onSurfaceVariant: AppColors.secondary,
    outline: Colors.transparent,
    outlineVariant: AppColors.secondary,
    shadow: AppColors.primaryDefault,
    scrim: AppColors.secondary,
    inverseSurface: AppColors.secondary,
    onInverseSurface: AppColors.secondary,
    inversePrimary: AppColors.secondary,
    surfaceTint: AppColors.secondary,
  );
  static const MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap;
}

class AppInputDecorationTheme {
  static int errorMaxLines = 2;
  static Color iconColor = AppColors.primary;
  static Color prefixIconColor = AppColors.primary.shade900;
  static Color suffixIconColor = AppColors.primary.shade900;
  static bool filled = true;
  static Color fillColor = Colors.transparent;
  static FloatingLabelAlignment floatingLabelAlignment = FloatingLabelAlignment.start;
  static FloatingLabelBehavior floatingLabelBehavior = FloatingLabelBehavior.auto;
  static InputBorder? border = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFC6C1BB),
      width: 2,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static OutlineInputBorder enabledBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFC6C1BB),
      width: 2,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static OutlineInputBorder disabledBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFC6C1BB),
      width: 2,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static OutlineInputBorder errorBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.errorDefault,
      width: 2,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static OutlineInputBorder focusedBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.primaryFocus,
      width: 2,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static InputBorder? focusedErrorBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.errorHover,
      width: 1,
    ),
    borderRadius: AppRadius.extraLarge,
  );
  static EdgeInsetsGeometry? contentPadding = const EdgeInsets.only(
    left: 35,
    right: 35,
    top: 11.25,
    bottom: 11.25,
  );

  static TextStyle? labelStyle;
  static TextStyle? floatingLabelStyle;
  static TextStyle? helperStyle;
  static TextStyle? hintStyle;
  static TextStyle? errorStyle;
  static TextStyle? prefixStyle;
  static TextStyle? suffixStyle;
  static TextStyle? counterStyle;

  static int? helperMaxLines;
  static bool isDense = false;
  static bool isCollapsed = false;
  static BorderSide? outlineBorder;
  static Color focusColor = AppColors.whiteSwatch;
  static Color hoverColor = Colors.transparent;
  static bool alignLabelWithHint = false;
  static BoxConstraints? constraints;
  static BorderSide? activeIndicatorBorder;

  static InputDecorationTheme buildTheme(ThemeData themeData, BuildContext context) {
    final AppSize size = AppSize(context);
    final isMobile = DeviceHelper.isMobile(context);

    return themeData.inputDecorationTheme.copyWith(
      constraints: !isMobile
          ? const BoxConstraints(
              minHeight: tabletAndAboveCTAHeight,
              minWidth: 344,
              maxWidth: 426,
            )
          : BoxConstraints(
              minHeight: mobileCTAHeight,
              minWidth: 344,
              maxWidth: math.max(size.screenWidth * .8, 344),
            ),
      hintStyle: themeData.textTheme.bodyMedium?.copyWith(
        color: AppColors.whiteSwatch,
        fontWeight: FontWeight.w200,
      ),
      labelStyle: themeData.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      floatingLabelStyle: themeData.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class AppTextThemeData {
  static TextTheme buildTheme(ThemeData themeData, BuildContext context, double fontSizeIndex) {
    final TextSize textSize = TextSize(fontSizeIndex: fontSizeIndex);
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: textSize.displayLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        displayMedium: TextStyle(
          fontSize: textSize.displayMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        displaySmall: TextStyle(
          fontSize: textSize.displaySmall,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        headlineLarge: TextStyle(
          fontSize: textSize.headingLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        headlineMedium: TextStyle(
          fontSize: textSize.headingMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        headlineSmall: TextStyle(
          fontSize: textSize.headingSmall,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        titleLarge: TextStyle(
          fontSize: textSize.titleLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        titleMedium: TextStyle(
          fontSize: textSize.titleMedium,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        titleSmall: TextStyle(
          fontSize: textSize.titleSmall,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        labelLarge: TextStyle(
          fontSize: textSize.labelLarge,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        labelMedium: TextStyle(
          fontSize: textSize.labelMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        labelSmall: TextStyle(
          fontSize: textSize.labelSmall,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDefault,
        ),
        bodyLarge: TextStyle(
          fontSize: textSize.bodyLarge,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        bodyMedium: TextStyle(
          fontSize: textSize.bodyMedium,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
        bodySmall: TextStyle(
          fontSize: textSize.bodySmall,
          fontWeight: FontWeight.w400,
          color: AppColors.primaryDefault,
        ),
      ),
    );
  }
}

class AppPopupMenuThemeData {
  static PopupMenuThemeData buildTheme(ThemeData themeData, BuildContext context) {
    return themeData.popupMenuTheme.copyWith(
      textStyle: themeData.textTheme.bodyMedium,
    );
  }
}

class AppCheckboxThemeData {
  static WidgetStateProperty<MouseCursor?> mouseCursor = WidgetStateProperty.resolveWith<MouseCursor?>(
    (states) {
      if (states.contains(WidgetState.disabled)) {
        return SystemMouseCursors.forbidden;
      }
      return SystemMouseCursors.click;
    },
  );
  static WidgetStateProperty<Color?> fillColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      if (states.contains(WidgetState.pressed)) {
        return Colors.transparent;
      }
      return Colors.transparent;
    },
  );
  static WidgetStateProperty<Color?> checkColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade500;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade200;
      }
      return AppColors.whiteSwatch;
    },
  );
  static WidgetStateProperty<Color?> overlayColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary;
      }
      return AppColors.primary.shade200;
    },
  );
  static double? splashRadius = 6;
  static MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap;
  static VisualDensity? visualDensity = VisualDensity.compact;
  static OutlinedBorder? shape = const RoundedRectangleBorder(
    borderRadius: AppRadius.small,
  );
  static BorderSide? side = BorderSide(
    color: AppColors.primary,
    width: 1.25,
  );
}

class AppRadioThemeData {
  static WidgetStateProperty<MouseCursor?> mouseCursor = WidgetStateProperty.resolveWith<MouseCursor?>(
    (states) {
      if (states.contains(WidgetState.disabled)) {
        return SystemMouseCursors.forbidden;
      }
      return SystemMouseCursors.click;
    },
  );
  static WidgetStateProperty<Color?> fillColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary.shade400;
      }
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade400;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade400;
      }
      return AppColors.primary.shade200;
    },
  );
  static WidgetStateProperty<Color?> checkColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      return AppColors.primary.shade400;
    },
  );
  static WidgetStateProperty<Color?> overlayColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      if (states.contains(WidgetState.pressed)) {
        return AppColors.primary.shade400;
      }
      if (states.contains(WidgetState.hovered)) {
        return AppColors.primary.shade400;
      }
      return Colors.transparent;
    },
  );
  static double? splashRadius = 6;
  static MaterialTapTargetSize materialTapTargetSize = MaterialTapTargetSize.shrinkWrap;
  static VisualDensity? visualDensity = VisualDensity.compact;
}

class AppScrollbarThemeData {
  static WidgetStateProperty<bool?>? thumbVisibility = WidgetStateProperty.resolveWith<bool?>(
    (states) {
      if (states.contains(WidgetState.hovered)) {
        return true;
      }
      return false;
    },
  );

  static WidgetStateProperty<Color?>? thumbColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      return AppColors.primary.shade400;
    },
  );

  static WidgetStateProperty<bool?>? trackVisibility = WidgetStateProperty.resolveWith<bool?>(
    (states) {
      return false;
    },
  );

  static WidgetStateProperty<Color?>? trackColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      return Colors.transparent;
    },
  );

  static WidgetStateProperty<double?>? thickness = WidgetStateProperty.resolveWith<double?>(
    (states) {
      if (states.contains(WidgetState.hovered)) {
        return 6;
      }
      return 6;
    },
  );

  static Radius? radius = const Radius.circular(8);

  static WidgetStateProperty<Color?>? trackBorderColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      return Colors.transparent;
    },
  );

  static double? crossAxisMargin = -AppSpacing.sectionMargin / 2;

  static double? mainAxisMargin = 5.w;

  static double? minThumbLength = 16;

  static bool? interactive = true;
}

class AppTabBarTheme {
  static Decoration indicator = const BoxDecoration(
    color: Colors.transparent,
    border: Border(
      bottom: BorderSide(
        color: AppColors.primaryFocus,
        width: 3,
      ),
    ),
  );

  static Color indicatorColor = AppColors.primaryFocus;
  static TabBarIndicatorSize indicatorSize = TabBarIndicatorSize.tab;

  static Color dividerColor = Colors.transparent;
  static double dividerHeight = 3;

  static Color labelColor = AppColors.primaryFocus;
  static Color unselectedLabelColor = AppColors.primaryDefault;
  static EdgeInsetsGeometry labelPadding = const EdgeInsets.only(
    left: AppSpacing.groupMargin,
    right: AppSpacing.groupMargin,
  );

  static TextStyle? labelStyle;
  static TextStyle? unselectedLabelStyle;

  static WidgetStateProperty<Color?> overlayColor = WidgetStateProperty.resolveWith<Color?>(
    (states) {
      return Colors.transparent;
    },
  );
  static InteractiveInkFeatureFactory splashFactory = InkRipple.splashFactory;
  static WidgetStateProperty<MouseCursor?> mouseCursor = WidgetStateProperty.resolveWith<MouseCursor?>(
    (states) {
      if (states.contains(WidgetState.disabled)) {
        return SystemMouseCursors.forbidden;
      }
      return SystemMouseCursors.click;
    },
  );
  static TabAlignment tabAlignment = TabAlignment.start;

  static TabBarThemeData buildTheme(ThemeData themeData, BuildContext context) {
    return themeData.tabBarTheme.copyWith(
      labelStyle: themeData.textTheme.labelLarge?.copyWith(
        color: AppColors.primaryFocus,
      ),
      unselectedLabelStyle: themeData.textTheme.labelLarge?.copyWith(
        color: AppColors.primaryDefault,
      ),
    );
  }
}

bool isDesktop = AppBreakpoints.isDesktop || AppBreakpoints.isLargeDesktop || AppBreakpoints.isTablet;
// Equivalent to the width of an iphone X
double kMainBodyWidth = (isDesktop ? 350 : 410) - AppSpacing.pageMargin - AppSpacing.sectionMargin;

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

class DeviceHelper {
  // Définition des breakpoints (modifiables selon ta cible)
  static const double _mobileMaxWidth = 480;
  static const double _tabletMaxWidth = 900;
  static const double _desktopMaxWidth = 1440;

  // largeDesktop = > _desktopMaxWidth

  /// Renvoie le DeviceType en fonction de la largeur du contexte
  static DeviceType getDeviceType(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    if (width <= _mobileMaxWidth) {
      return DeviceType.mobile;
    } else if (width <= _tabletMaxWidth) {
      return DeviceType.tablet;
    } else if (width <= _desktopMaxWidth) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Quelques helpers booléens pratiques
  static bool isMobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) => getDeviceType(context) == DeviceType.desktop;

  static bool isLargeDesktop(BuildContext context) => getDeviceType(context) == DeviceType.largeDesktop;

  static double kMainBodyWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    final appSize = AppSize(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return (appSize.screenWidth - AppSpacing.pageMargin * 2);
      case DeviceType.tablet:
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 536;
    }
  }
}
