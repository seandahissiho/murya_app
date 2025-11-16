import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:murya/config/DS.dart';
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints;

//kButtonMinWidth
const double kButtonMinWidth = 144;

enum AppXButtonSize { SMALL, MEDIUM, LARGE }

enum AppXButtonState { ENABLED, DISABLED }

enum AppXButtonType { PRIMARY, SECONDARY }

class AppXButton extends StatelessWidget {
  const AppXButton({
    super.key,
    this.text,
    this.textStyle,
    required this.onPressed,
    this.onLongPress,
    this.leftIcon,
    this.leftIconPath,
    this.rightIcon,
    this.rightIconPath,
    this.size = AppXButtonSize.SMALL,
    this.disabled = false,
    this.type = AppXButtonType.PRIMARY,
    this.bgColor,
    this.fgColor,
    this.borderColor,
    this.hoverColor,
    this.onPressedColor,
    this.disabledColor = AppColors.primaryDisabled,
    this.autoResize = true,
    this.borderLineWidth = 1,
    this.removePaddings = false,
    this.horizontalAlignment = MainAxisAlignment.center,
    this.maxWidth,
    required this.isLoading,
    this.loadingAlignment = Alignment.centerRight,
    this.radius,
    this.height,
    this.iconSize = 24,
    this.onlyLeftRounded = false,
    this.onlyRightRounded = false,
  });

  final String? text;
  final TextStyle? textStyle;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? onLongPress;
  final Widget? leftIcon;
  final String? leftIconPath;
  final Widget? rightIcon;
  final String? rightIconPath;
  final AppXButtonSize size;
  final bool disabled;
  final AppXButtonType type;
  final Color? bgColor;
  final Color? fgColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? onPressedColor;
  final Color? disabledColor;
  final bool autoResize;
  final double borderLineWidth;
  final bool removePaddings;
  final MainAxisAlignment horizontalAlignment;
  final double? maxWidth;
  final bool isLoading;
  final Alignment loadingAlignment;
  final double? radius;
  final double? height;
  final double iconSize;
  final bool onlyLeftRounded;
  final bool onlyRightRounded;

  (double?, double?, double?, double?) get getPositionParams {
    switch (loadingAlignment) {
      case Alignment.center:
        return (0, 0, 0, 0);
      case Alignment.centerLeft:
        return (AppSpacing.containerInsideMargin, null, 0, 0);
      case Alignment.centerRight:
        return (null, AppSpacing.containerInsideMargin, 0, 0);
      case Alignment.topCenter:
        return (0, 0, 0, null);
      case Alignment.topLeft:
        return (0, null, 0, null);
      case Alignment.topRight:
        return (null, 0, 0, null);
      case Alignment.bottomCenter:
        return (0, 0, null, 0);
      case Alignment.bottomLeft:
        return (0, null, null, 0);
      case Alignment.bottomRight:
        return (null, 0, null, 0);
      default:
        return (null, null, null, null);
    }
  }

  WidgetStateProperty<OutlinedBorder?>? get shape {
    if (onlyLeftRounded) {
      return WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius ?? 64),
            bottomLeft: Radius.circular(radius ?? 64),
          ),
        ),
      );
    }

    if (onlyRightRounded) {
      return WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(radius ?? 64),
            bottomRight: Radius.circular(radius ?? 64),
          ),
        ),
      );
    }

    return radius != null
        ? WidgetStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius!),
            ),
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);

    var children = <Widget>[];
    bool onlyOneIcon = leftIcon != null && (rightIcon == null && rightIconPath == null) ||
        rightIcon != null && (leftIcon == null && leftIconPath == null) ||
        leftIconPath != null && (rightIcon == null && rightIconPath == null) ||
        rightIconPath != null && (leftIcon == null && leftIconPath == null);

    onlyOneIcon = onlyOneIcon && text == null;

    if (!onlyOneIcon) {
      // children.add(AppSpacing.elementMarginBox);
      if (leftIcon == null && leftIconPath == null && (rightIconPath != null || rightIcon != null)) {
        // children.add(AppSpacing.tinyMarginBox);
      }
    }

    if (leftIcon != null || leftIconPath != null) {
      children.add(Padding(
        padding: EdgeInsets.only(
          right: removePaddings
              ? 0
              : text != null
                  ? (size == AppXButtonSize.LARGE
                      ? 18
                      : size == AppXButtonSize.MEDIUM
                          ? 14
                          : 9)
                  : rightIcon != null
                      ? (size == AppXButtonSize.SMALL ? 5 : 10)
                      : 0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: leftIcon != null
              ? leftIcon!
              : SizedBox(
                  height: iconSize,
                  width: iconSize,
                  child: SvgPicture.asset(
                    leftIconPath!,
                    fit: BoxFit.scaleDown,
                    height: iconSize,
                    width: iconSize,
                    colorFilter: ColorFilter.mode(
                      fgColor ?? theme.elevatedButtonTheme.style?.iconColor?.resolve({}) ?? AppColors.whiteSwatch,
                      BlendMode.srcATop,
                    ),
                  ),
                ),
        ),
      ));
    }
    if (text != null) {
      children.add(Flexible(
        // flex: 10,
        // fit: FlexFit.loose,
        child: Text(
          text!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isMobile ? null : theme.textTheme.bodyLarge?.copyWith(color: fgColor ?? Colors.white),
          // style: textStyle?.copyWith(color: AppColors.primary.shade900),
        ),
      ));
    }

    if (rightIcon != null || rightIconPath != null) {
      children.add(Padding(
        padding: EdgeInsets.only(
          left: removePaddings
              ? 0
              : text != null
                  ? (size == AppXButtonSize.LARGE
                      ? 18
                      : size == AppXButtonSize.MEDIUM
                          ? 14
                          : 9)
                  : leftIcon != null
                      ? (size == AppXButtonSize.SMALL ? 5 : 10)
                      : 0,
        ),
        child: rightIcon != null
            ? rightIcon!
            : SizedBox(
                height: iconSize,
                width: iconSize,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SvgPicture.asset(
                    rightIconPath!,
                    fit: BoxFit.scaleDown,
                    height: iconSize,
                    width: iconSize,
                    colorFilter: ColorFilter.mode(
                      fgColor ?? theme.elevatedButtonTheme.style?.iconColor?.resolve({}) ?? AppColors.whiteSwatch,
                      BlendMode.srcATop,
                    ),
                  ),
                ),
              ),
      ));
    }

    if (!onlyOneIcon) {
      // children.add(AppSpacing.elementMarginBox);
      if (rightIcon == null && rightIconPath == null && (leftIconPath != null || leftIcon != null)) {
        children.add(AppSpacing.tinyMarginBox);
      }
    }

    var positionParams = getPositionParams;

    return Theme(
      data: ThemeData(elevatedButtonTheme: theme.elevatedButtonTheme),
      child: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              isLoading ? Colors.white70 : Colors.transparent,
              BlendMode.srcATop,
            ),
            child: ElevatedButton(
              style: theme.elevatedButtonTheme.style?.copyWith(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return onPressedColor ??
                          theme.elevatedButtonTheme.style?.backgroundColor?.resolve({WidgetState.pressed});
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return hoverColor ??
                          theme.elevatedButtonTheme.style?.backgroundColor?.resolve({WidgetState.hovered});
                    }
                    if (states.contains(WidgetState.disabled)) {
                      return disabledColor ??
                          theme.elevatedButtonTheme.style?.backgroundColor?.resolve({WidgetState.disabled});
                    }
                    return bgColor ?? theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states);
                  },
                ),
                foregroundColor: fgColor != null ? WidgetStatePropertyAll(fgColor) : null,
                side: WidgetStateProperty.resolveWith<BorderSide?>(
                  (states) {
                    return borderColor != null
                        ? BorderSide(
                            color: borderColor!,
                            width: borderLineWidth,
                          )
                        : theme.elevatedButtonTheme.style?.side?.resolve(states);
                  },
                ),
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return onPressedColor ??
                          theme.elevatedButtonTheme.style?.overlayColor?.resolve({WidgetState.pressed});
                    }
                    if (states.contains(WidgetState.hovered)) {
                      return hoverColor ??
                          theme.elevatedButtonTheme.style?.overlayColor?.resolve({WidgetState.hovered});
                    }
                    if (states.contains(WidgetState.disabled)) {
                      return disabledColor ??
                          theme.elevatedButtonTheme.style?.overlayColor?.resolve({WidgetState.disabled});
                    }
                    return theme.elevatedButtonTheme.style?.overlayColor?.resolve(states);
                  },
                ),
                shape: shape,
                maximumSize: height == null
                    ? null
                    : WidgetStateProperty.all<Size>(
                        Size(
                          maxWidth ??
                              ResponsiveBreakpoints.of(context).breakpoints.elementAtOrNull(1)?.start ??
                              AppBreakpoints.mobile,
                          height!,
                        ),
                      ),
                minimumSize: height == null
                    ? null
                    : WidgetStateProperty.all<Size>(Size(
                        maxWidth ??
                            ResponsiveBreakpoints.of(context).breakpoints.elementAtOrNull(1)?.start ??
                            AppBreakpoints.mobile,
                        height!,
                      )),
                fixedSize: height == null
                    ? null
                    : WidgetStateProperty.all<Size>(
                        Size(
                          maxWidth ??
                              ResponsiveBreakpoints.of(context).breakpoints.elementAtOrNull(1)?.start ??
                              AppBreakpoints.mobile,
                          height!,
                        ),
                      ),
              ),
              onPressed: disabled
                  ? null
                  : () {
                      if (isLoading == true) return;
                      onPressed?.call();
                    },
              onLongPress: disabled
                  ? null
                  : () {
                      if (isLoading == true) return;
                      onLongPress?.call();
                    },
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: height ?? theme.elevatedButtonTheme.style?.maximumSize?.resolve({})?.height ?? 40,
                  maxWidth: maxWidth ??
                      ResponsiveBreakpoints.of(context).breakpoints.elementAtOrNull(1)?.start ??
                      AppBreakpoints.mobile,
                ),
                child: Stack(
                  children: [
                    Row(
                      mainAxisSize: autoResize ? MainAxisSize.min : MainAxisSize.max,
                      mainAxisAlignment: horizontalAlignment,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
                    if (disabled) ...[
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: shape?.resolve({}) is RoundedRectangleBorder
                                ? (shape!.resolve({}) as RoundedRectangleBorder).borderRadius
                                : null,
                            color: disabledColor?.withAlpha(150),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) ...[
            Positioned(
              left: positionParams.$1,
              right: positionParams.$2,
              top: positionParams.$3,
              bottom: positionParams.$4,
              child: SizedBox(
                height: 20,
                width: 20,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CupertinoActivityIndicator(
                    color: bgColor ?? AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
