import 'dart:ui';

// import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';

class GlassContainer extends StatelessWidget {
  final bool roundTopCorners;
  final bool roundBottomCorners;
  final bool opaque;
  final bool lighter;
  final bool darker;
  final Widget? child;
  final double? width;
  final double? height;
  final bool transparent;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final BoxConstraints? constraints;
  final Color borderColor;

  const GlassContainer({
    super.key,
    this.roundTopCorners = true,
    this.roundBottomCorners = true,
    this.opaque = false,
    this.lighter = false,
    this.darker = false,
    this.child,
    this.width,
    this.height,
    this.transparent = false,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = 12.0,
    this.constraints,
    this.borderColor = Colors.black38,
  });

  @override
  Widget build(BuildContext context) {
    final AppSize appSize = AppSize(context);
    return BlurryContainer(
      blur: (transparent || lighter) ? 0 : (opaque ? 500 : 100),
      width: width,
      height: height,
      elevation: (transparent || lighter) ? 0 : 2,
      color: AppColors.backgroundColor,
      // color: (transparent || lighter) ? Colors.transparent : const Color(0xFFFCDFB8).withAlpha(opaque ? 80 : 40),
      // shadowColor: const Color(0xFFFCDFB8),
      // padding: padding,
      borderRadius: _getBorderRadius(),
      borderColor: transparent ? Colors.transparent : borderColor,
      child: ClipRRect(
        borderRadius: _getBorderRadius(),
        child: Padding(
          padding: padding,
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    ); // return LiquidGlass(
    //   shape: LiquidRoundedRectangle(borderRadius: Radius.circular(borderRadius)),
    //   settings: LiquidGlassSettings(
    //     glassColor: Color.fromARGB(0, AppColors.backgroundColor.r.floor(), AppColors.backgroundColor.g.floor(),
    //         AppColors.backgroundColor.b.floor()),
    //     blur: 200,
    //     thickness: 10,
    //   ),
    //   glassContainsChild: false,
    //   child: Container(
    //     color: AppColors.backgroundColor.withAlpha(50),
    //     child: ClipRRect(
    //       borderRadius: _getBorderRadius(),
    //       child: Container(
    //         width: width,
    //         height: height,
    //         constraints: constraints ??
    //             BoxConstraints(
    //               maxHeight: appSize.screenHeight,
    //               maxWidth: appSize.screenWidth,
    //             ),
    //         padding: padding ?? EdgeInsets.zero,
    //         decoration: BoxDecoration(
    //           borderRadius: _getBorderRadius(),
    //           // gradient: transparent
    //           //     ? null
    //           //     : LinearGradient(
    //           //         begin: Alignment.topLeft,
    //           //         end: Alignment.bottomRight,
    //           //         colors: [
    //           //           AppColors.backgroundColor.withValues(alpha: 0.125 * (lighter ? 6 : 3)),
    //           //           AppColors.backgroundColor.withValues(alpha: 0.125 * (lighter ? 3 : 1.5)),
    //           //         ],
    //           //       ),
    //           // border: Border.all(
    //           //   color: AppColors.whiteSwatch.withAlpha(62),
    //           //   width: transparent ? 0 : 1.5,
    //           // ),
    //         ),
    //         child: ClipRRect(borderRadius: _getBorderRadius(), child: child),
    //       ),
    //     ),
    //   ),
    // );
    return ClipRRect(
      borderRadius: _getBorderRadius(),
      child: BackdropFilter(
        // adjust sigmaX/Y for more or less blur
        filter: ImageFilter.blur(
          sigmaX: 200.0,
          sigmaY: 200.0,
        ),
        child: Container(
          width: width,
          height: height,
          constraints: constraints ??
              BoxConstraints(
                maxHeight: appSize.screenHeight,
                maxWidth: appSize.screenWidth,
              ),
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: _getBorderRadius(),
            gradient: transparent
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundColor.withValues(alpha: 0.125 * (lighter ? 6 : 3)),
                      AppColors.backgroundColor.withValues(alpha: 0.125 * (lighter ? 3 : 1.5)),
                    ],
                  ),
            border: Border.all(
              color: AppColors.whiteSwatch.withAlpha(62),
              width: transparent ? 0 : 1.5,
            ),
          ),
          child: ClipRRect(borderRadius: _getBorderRadius(), child: child),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    if (roundTopCorners && roundBottomCorners) {
      return BorderRadius.circular(borderRadius);
    } else if (roundTopCorners) {
      return BorderRadius.only(
        topLeft: Radius.circular(borderRadius),
        topRight: Radius.circular(borderRadius),
      );
    } else if (roundBottomCorners) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      );
    } else {
      return BorderRadius.zero;
    }
  }
}

// import 'dart:ui';
//
// import 'package:flutter/material.dart';

//
// class GlassContainer extends StatelessWidget {
//   final bool roundTopCorners;
//   final bool roundBottomCorners;
//   final bool opaque;
//   final bool lighter;
//   final Widget? child;
//   final double? width;
//   final double? height;
//   final bool transparent;
//   final EdgeInsetsGeometry? padding;
//   final double borderRadius;
//   final BoxConstraints? constraints;
//
//   const GlassContainer({
//     super.key,
//     this.roundTopCorners = true,
//     this.roundBottomCorners = true,
//     this.opaque = false,
//     this.lighter = false,
//     this.child,
//     this.width,
//     this.height,
//     this.transparent = false,
//     this.padding,
//     this.borderRadius = 14.0,
//     this.constraints,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final AppSize appSize = AppSize(context);
//     return BackdropFilter(
//       // adjust sigmaX/Y for more or less blur
//       filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
//       child: ClipRRect(
//         borderRadius: _getBorderRadius(),
//         child: Container(
//           width: width,
//           height: height,
//           constraints: constraints ??
//               BoxConstraints(
//                 maxHeight: appSize.screenHeight,
//                 maxWidth: appSize.screenWidth,
//               ),
//           padding: padding ?? EdgeInsets.zero,
//           decoration: BoxDecoration(
//             borderRadius: _getBorderRadius(),
//             border: transparent ? null : Border.all(color: AppColors.primary.withAlpha(62), width: 1.5),
//             gradient: transparent
//                 ? null
//                 : LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       AppColors.backgroundColor, //.withValues(alpha: 0.125 * (lighter ? 6 : 3)),
//                       AppColors.backgroundColor, //.withValues(alpha: 0.125 * (lighter ? 3 : 1.5)),
//                     ],
//                   ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
//
//   BorderRadius _getBorderRadius() {
//     if (roundTopCorners == true && roundBottomCorners == true) {
//       // return BorderRadius.zero;
//       return BorderRadius.circular(borderRadius);
//     }
//
//     if (roundTopCorners && !roundBottomCorners) {
//       // return BorderRadius.zero;
//       return BorderRadius.only(
//         topLeft: Radius.circular(borderRadius),
//         topRight: Radius.circular(borderRadius),
//         bottomLeft: Radius.zero,
//         bottomRight: Radius.zero,
//       );
//     }
//
//     if (!roundTopCorners && roundBottomCorners) {
//       return BorderRadius.only(
//         bottomLeft: Radius.circular(borderRadius),
//         bottomRight: Radius.circular(borderRadius),
//         topLeft: Radius.zero,
//         topRight: Radius.zero,
//       );
//     }
//
//     if (roundTopCorners) {
//       return BorderRadius.only(
//         topLeft: Radius.circular(borderRadius),
//         topRight: Radius.circular(borderRadius),
//         bottomLeft: Radius.zero,
//         bottomRight: Radius.zero,
//       );
//     }
//     if (roundBottomCorners) {
//       return BorderRadius.only(
//         bottomLeft: Radius.circular(borderRadius),
//         bottomRight: Radius.circular(borderRadius),
//         topLeft: Radius.zero,
//         topRight: Radius.zero,
//       );
//     }
//     return BorderRadius.zero;
//   }
// }

/// A widget that creates a container with a blurred background.
///
/// The [child] widget is displayed over the blurred background.
class BlurryContainer extends StatelessWidget {
  /// This widget will be shown over blurry container.
  final Widget child;

  /// [height] of blurry container.
  final double? height;

  /// [width] of blurry container.
  final double? width;

  /// [elevation] of blurry container.
  ///
  /// Defaults to `0`.
  final double elevation;

  /// Shadow color of container.
  ///
  /// Defaults to `Colors.black24`.
  final Color shadowColor;

  /// The [blur] will control the amount of sigmaX and sigmaY.
  ///
  /// Defaults to `5`.
  final double blur;

  /// [padding] adds the [EdgeInsetsGeometry] to given [child].
  ///
  /// Defaults to `const EdgeInsets.all(8)`.
  final EdgeInsetsGeometry padding;

  /// Background color of container.
  ///
  /// Defaults to `Colors.transparent`.
  final Color color;

  /// [borderRadius] of blurry container.
  final BorderRadius borderRadius;

  /// [border] of blurry container.
  final Color borderColor;

  const BlurryContainer({
    Key? key,
    required this.child,
    this.height,
    this.width,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.shadowColor = Colors.black26,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderColor = Colors.transparent,
  }) : super(key: key);

  /// Creates a blurry container whose [width] and [height] are equal.
  const BlurryContainer.square({
    Key? key,
    required this.child,
    double? dimension,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.shadowColor = Colors.black26,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderColor = Colors.transparent,
  })  : width = dimension,
        height = dimension,
        super(key: key);

  /// Creates a blurry container whose [width] and [height] are equal.
  const BlurryContainer.expand({
    Key? key,
    required this.child,
    this.blur = 5,
    this.elevation = 0,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.transparent,
    this.shadowColor = Colors.black26,
    this.borderRadius = BorderRadius.zero,
    this.borderColor = Colors.transparent,
  })  : width = double.infinity,
        height = double.infinity,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: elevation,
      shadowColor: shadowColor,
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
