import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:responsive_framework/responsive_framework.dart' show ResponsiveBreakpoints;

//kButtonMinWidth
const double kButtonMinWidth = 144;

class AppXButton extends StatefulWidget {
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
    this.disabled = false,
    this.shadowColor,
    this.bgColor,
    this.fgColor,
    this.borderColor,
    this.hoverColor,
    this.onPressedColor,
    this.disabledColor = AppColors.primaryDisabled,
    this.elevation,
    this.shrinkWrap = true,
    this.borderLineWidth = 1,
    this.removePaddings = false,
    this.horizontalAlignment = MainAxisAlignment.center,
    this.maxWidth,
    required this.isLoading,
    this.loadingAlignment = Alignment.centerRight,
    this.radius,
    this.height,
    this.iconSize = 24,
    this.iconTextPadding = 9,
    this.iconOnlyPadding = 5,
    this.onlyLeftRounded = false,
    this.onlyRightRounded = false,
    this.children,
  });

  final String? text;
  final TextStyle? textStyle;
  final GestureTapCallback? onPressed;
  final GestureTapCallback? onLongPress;
  final Widget? leftIcon;
  final String? leftIconPath;
  final Widget? rightIcon;
  final String? rightIconPath;
  final bool disabled;
  final Color? bgColor;
  final Color? fgColor;
  final Color? shadowColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Color? onPressedColor;
  final Color? disabledColor;
  final int? elevation;
  final bool shrinkWrap;
  final double borderLineWidth;
  final bool removePaddings;
  final MainAxisAlignment horizontalAlignment;
  final double? maxWidth;
  final bool isLoading;
  final Alignment loadingAlignment;
  final double? radius;
  final double? height;
  final double iconSize;
  final double iconTextPadding;
  final double iconOnlyPadding;
  final bool onlyLeftRounded;
  final bool onlyRightRounded;
  final List<Widget>? children;

  @override
  State<AppXButton> createState() => _AppXButtonState();
}

class _AppXButtonState extends State<AppXButton> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;
  int _pressSeq = 0;
  // = 100ms (ton AnimatedContainer) + un petit buffer
  static const Duration _pressAnim = Duration(milliseconds: 150);
  static const Duration _pressHold = Duration(milliseconds: 110); // = ton AnimatedContainer (100ms) + marge

  // Tune these to match the exact Figma numbers.
  static const double _hardShadowOffsetY = 5;
  static const Color _focusGlowColor = Color(0xFFB0C6EA);

  bool get _isDisabled => widget.disabled || widget.onPressed == null;

  Set<WidgetState> _states() {
    final s = <WidgetState>{};
    if (_isDisabled) s.add(WidgetState.disabled);
    if (_hovered) s.add(WidgetState.hovered);
    if (_focused) s.add(WidgetState.focused);
    if (_pressed) s.add(WidgetState.pressed);
    return s;
  }

  (double?, double?, double?, double?) get _loadingPositionParams {
    switch (widget.loadingAlignment) {
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

  BorderRadius _resolveBorderRadius(ThemeData theme, Set<WidgetState> states) {
    // 1) Explicit per-widget overrides (same behavior as previous shape getter).
    if (widget.onlyLeftRounded) {
      final r = widget.radius ?? 64;
      return BorderRadius.only(
        topLeft: Radius.circular(r),
        bottomLeft: Radius.circular(r),
      );
    }

    if (widget.onlyRightRounded) {
      final r = widget.radius ?? 64;
      return BorderRadius.only(
        topRight: Radius.circular(r),
        bottomRight: Radius.circular(r),
      );
    }

    if (widget.radius != null) {
      return BorderRadius.circular(widget.radius!);
    }

    // 2) Fallback to ElevatedButton theme shape if it is a RoundedRectangleBorder.
    final themedShape = theme.elevatedButtonTheme.style?.shape?.resolve(states);
    if (themedShape is RoundedRectangleBorder) {
      final brg = themedShape.borderRadius;
      if (brg is BorderRadius) return brg;
      return brg.resolve(Directionality.of(context));
    }

    // 3) Safe default.
    return BorderRadius.circular(16);
  }

  BorderSide _resolveSide(ThemeData theme, Set<WidgetState> states) {
    if (widget.borderColor != null) {
      return BorderSide(
        color: widget.borderColor!,
        width: widget.borderLineWidth,
      );
    }

    return theme.elevatedButtonTheme.style?.side?.resolve(states) ??
        const BorderSide(width: 0, color: Colors.transparent);
  }

  Color _resolveForegroundColor(ThemeData theme, Set<WidgetState> states) {
    return widget.fgColor ?? theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states) ?? AppColors.whiteSwatch;
  }

  Color _resolveIconColor(ThemeData theme, Set<WidgetState> states) {
    return widget.fgColor ?? theme.elevatedButtonTheme.style?.iconColor?.resolve(states) ?? AppColors.whiteSwatch;
  }

  Color _resolveBackgroundColor(ThemeData theme, Set<WidgetState> states) {
    final style = theme.elevatedButtonTheme.style;

    if (states.contains(WidgetState.disabled)) {
      return widget.disabledColor ??
          style?.backgroundColor?.resolve({WidgetState.disabled}) ??
          style?.backgroundColor?.resolve(states) ??
          AppColors.primaryDisabled;
    }

    if (states.contains(WidgetState.pressed)) {
      return widget.onPressedColor ??
          style?.backgroundColor?.resolve({WidgetState.pressed}) ??
          widget.bgColor ??
          style?.backgroundColor?.resolve(states) ??
          theme.colorScheme.primary;
    }

    if (states.contains(WidgetState.hovered)) {
      return widget.hoverColor ??
          style?.backgroundColor?.resolve({WidgetState.hovered}) ??
          widget.bgColor ??
          style?.backgroundColor?.resolve(states) ??
          theme.colorScheme.primary;
    }

    return widget.bgColor ?? style?.backgroundColor?.resolve(states) ?? theme.colorScheme.primary;
  }

  TextStyle _resolveTextStyle(ThemeData theme, Set<WidgetState> states, {required bool isMobile}) {
    final fg = _resolveForegroundColor(theme, states);

    // If the caller gives an explicit textStyle, respect it (but force color by default).
    if (widget.textStyle != null) {
      final ts = widget.textStyle!;
      return ts.copyWith(color: ts.color ?? fg);
    }

    // Preserve previous behavior:
    // - mobile: let ElevatedButtonTheme drive it
    // - desktop/tablet: use labelLarge with fg
    final themed = theme.elevatedButtonTheme.style?.textStyle?.resolve(states);
    if (isMobile) {
      return (themed ?? theme.textTheme.labelLarge ?? const TextStyle()).copyWith(color: fg);
    }

    return (theme.textTheme.labelLarge ?? themed ?? const TextStyle()).copyWith(color: fg);
  }

  double _resolveMaxWidth(BuildContext context) {
    return widget.maxWidth ?? double.infinity;
    ResponsiveBreakpoints.of(context).breakpoints.elementAtOrNull(1)?.start ?? AppBreakpoints.mobile;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);

    final states = _states();
    final fg = _resolveForegroundColor(theme, states);
    final iconColor = _resolveIconColor(theme, states);
    final bg = _resolveBackgroundColor(theme, states);
    final BorderSide side = _resolveSide(theme, states);
    final borderRadius = _resolveBorderRadius(theme, states);

    final double effectiveHeight =
        widget.height ?? theme.elevatedButtonTheme.style?.maximumSize?.resolve({})?.height ?? 40;
    final double maxWidth = _resolveMaxWidth(context);

    final bool onlyOneIconBase =
        (widget.leftIcon != null && (widget.rightIcon == null && widget.rightIconPath == null)) ||
            (widget.rightIcon != null && (widget.leftIcon == null && widget.leftIconPath == null)) ||
            (widget.leftIconPath != null && (widget.rightIcon == null && widget.rightIconPath == null)) ||
            (widget.rightIconPath != null && (widget.leftIcon == null && widget.leftIconPath == null));

    final bool onlyOneIcon = onlyOneIconBase && widget.text == null;

    final List<Widget> children = <Widget>[];

    if (widget.leftIcon != null || widget.leftIconPath != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            right: widget.removePaddings
                ? 0
                : widget.text != null
                    ? widget.iconTextPadding
                    : widget.rightIcon != null
                        ? widget.iconOnlyPadding
                        : 0,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: widget.leftIcon != null
                ? widget.leftIcon!
                : SizedBox(
                    height: widget.iconSize,
                    width: widget.iconSize,
                    child: SvgPicture.asset(
                      widget.leftIconPath!,
                      fit: BoxFit.scaleDown,
                      height: widget.iconSize,
                      width: widget.iconSize,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcATop),
                    ),
                  ),
          ),
        ),
      );
    }

    if (widget.text != null) {
      final textWidget = Text(
        widget.text!,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _resolveTextStyle(theme, states, isMobile: isMobile),
      );

      children.add(
        widget.shrinkWrap ? textWidget : Flexible(child: textWidget),
      );
    }

    if (widget.rightIcon != null || widget.rightIconPath != null) {
      children.add(
        Padding(
          padding: EdgeInsets.only(
            left: widget.removePaddings
                ? 0
                : widget.text != null
                    ? widget.iconTextPadding
                    : widget.leftIcon != null
                        ? widget.iconOnlyPadding
                        : 0,
          ),
          child: widget.rightIcon != null
              ? widget.rightIcon!
              : SizedBox(
                  height: widget.iconSize,
                  width: widget.iconSize,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SvgPicture.asset(
                      widget.rightIconPath!,
                      fit: BoxFit.scaleDown,
                      height: widget.iconSize,
                      width: widget.iconSize,
                      colorFilter: ColorFilter.mode(iconColor, BlendMode.srcATop),
                    ),
                  ),
                ),
        ),
      );
    }

    if (!onlyOneIcon) {
      if (widget.rightIcon == null &&
          widget.rightIconPath == null &&
          (widget.leftIconPath != null || widget.leftIcon != null)) {
        children.add(AppSpacing.tinyMarginBox);
      }
    }

    final hardShadowColor =
        widget.shadowColor ?? theme.elevatedButtonTheme.style?.shadowColor?.resolve(states) ?? theme.shadowColor;

    final List<BoxShadow> shadows = <BoxShadow>[
      if (_focused && !_isDisabled)
        BoxShadow(
          color: _focusGlowColor.withValues(alpha: 0.55),
          blurRadius: 18,
          spreadRadius: 8,
          offset: Offset.zero,
        ),
      if (!_pressed && !_isDisabled)
        BoxShadow(
          color: hardShadowColor,
          offset: const Offset(0, _hardShadowOffsetY),
          blurRadius: 0,
          spreadRadius: 0,
        ),
    ];

    final double translateY = (_pressed && !_isDisabled) ? _hardShadowOffsetY : 0;

    final onTap = (!_isDisabled && !widget.isLoading)
        ? () {
            widget.onPressed?.call();
          }
        : null;

    final onLongPress = (!_isDisabled && !widget.isLoading)
        ? () {
            widget.onLongPress?.call();
          }
        : null;

    final positionParams = _loadingPositionParams;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            widget.isLoading ? Colors.white70 : Colors.transparent,
            BlendMode.srcATop,
          ),
          child: FocusableActionDetector(
            enabled: !_isDisabled && !widget.isLoading,
            onShowHoverHighlight: (v) => setState(() => _hovered = v),
            onShowFocusHighlight: (v) => setState(() => _focused = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.translationValues(0, translateY, 0),
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: shadows,
              ),
              child: Material(
                color: bg,
                shape: RoundedRectangleBorder(
                  borderRadius: borderRadius,
                  side: side,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: (onTap == null)
                      ? null
                      : () async {
                          // Pour clavier (Enter/Space) : pas de tapDown -> on force l’état pressed
                          if (!_pressed) setState(() => _pressed = true);

                          final int seq = ++_pressSeq;

                          // ✅ attendre la fin de l’animation de "descente"
                          await Future<void>.delayed(_pressAnim);
                          if (!mounted) return;
                          if (_pressSeq != seq) return; // un nouveau tap a pris le dessus
                          if (_isDisabled || widget.isLoading) return;

                          // ✅ action seulement à la fin
                          widget.onPressed?.call();

                          // ✅ remonter juste après (ou tu peux ajouter un petit délai)
                          await Future<void>.delayed(const Duration(milliseconds: 60));
                          if (!mounted) return;
                          if (_pressSeq != seq) return;
                          setState(() => _pressed = false);
                        },

                  onLongPress: onLongPress,

                  onTapDown: (_) {
                    if (_isDisabled || widget.isLoading) return;
                    ++_pressSeq; // invalide les tâches en cours
                    setState(() => _pressed = true);
                  },

                  // on ne remonte PAS ici
                  onTapUp: (_) {},

                  onTapCancel: () {
                    if (_isDisabled || widget.isLoading) return;
                    ++_pressSeq;
                    setState(() => _pressed = false);
                  },

                  borderRadius: borderRadius,
                  hoverColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,

                  child: widget.shrinkWrap
                      ? IntrinsicWidth(
                          child: _ButtonBody(
                            borderRadius: borderRadius,
                            side: side,
                            effectiveHeight: effectiveHeight,
                            maxWidth: maxWidth,
                            shrinkWrap: widget.shrinkWrap,
                            removePaddings: widget.removePaddings,
                            horizontalAlignment: widget.horizontalAlignment,
                            disabled: widget.disabled,
                            disabledColor: widget.disabledColor ?? AppColors.primaryDisabled,
                            children: widget.children ?? children,
                          ),
                        )
                      : _ButtonBody(
                          borderRadius: borderRadius,
                          side: side,
                          effectiveHeight: effectiveHeight,
                          maxWidth: maxWidth,
                          shrinkWrap: widget.shrinkWrap,
                          removePaddings: widget.removePaddings,
                          horizontalAlignment: widget.horizontalAlignment,
                          disabled: widget.disabled,
                          disabledColor: widget.disabledColor ?? AppColors.primaryDisabled,
                          children: widget.children ?? children,
                        ),
                ),
              ),
            ),
          ),
        ),
        if (widget.isLoading) ...[
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
                  color: widget.bgColor ?? AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ButtonBody extends StatelessWidget {
  const _ButtonBody({
    required this.borderRadius,
    required this.side,
    required this.effectiveHeight,
    required this.maxWidth,
    required this.shrinkWrap,
    required this.removePaddings,
    required this.horizontalAlignment,
    required this.children,
    required this.disabled,
    required this.disabledColor,
  });

  final BorderRadius borderRadius;
  final BorderSide side;
  final double effectiveHeight;
  final double maxWidth;
  final bool shrinkWrap;
  final bool removePaddings;
  final MainAxisAlignment horizontalAlignment;
  final List<Widget> children;
  final bool disabled;
  final Color disabledColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: side.color,
          width: side.width + 1,
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: effectiveHeight,
        maxWidth: shrinkWrap ? double.infinity : maxWidth,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: shrinkWrap
            ? (removePaddings ? 0 : AppSpacing.containerInsideMarginSmall)
            : AppSpacing.containerInsideMargin,
      ),
      child: SizedBox(
        height: effectiveHeight,
        child: Stack(
          children: [
            Center(
              child: shrinkWrap
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: horizontalAlignment,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: children,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: horizontalAlignment,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children,
                    ),
            ),
            if (disabled)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    color: disabledColor.withAlpha(150),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppXCloseButton extends StatelessWidget {
  final String destination;
  const AppXCloseButton({super.key, this.destination = AppRoutes.landing});

  @override
  Widget build(BuildContext context) {
    final double ctaHeight = DeviceHelper.isMobile(context) ? mobileCTAHeight : tabletAndAboveCTAHeight;
    return SizedBox(
      width: ctaHeight,
      height: ctaHeight,
      child: AppXButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            return;
          }
          navigateToPath(context, to: destination);
        },
        isLoading: false,
        // leftIconPath: AppIcons.searchBarCloseIconPath,
        removePaddings: true,
        leftIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppIcons.deleteDisabledIconPath,
            width: ctaHeight,
            height: ctaHeight,
          ),
        ),
        shadowColor: AppColors.borderMedium,
        bgColor: AppColors.backgroundColor,
        fgColor: AppButtonColors.secondarySurfaceDefault,
        borderColor: AppColors.borderMedium,
        hoverColor: AppButtonColors.secondarySurfaceHover,
        onPressedColor: AppButtonColors.secondarySurfacePressed,
      ),
    );
  }
}

class AppXReturnButton extends StatelessWidget {
  final String destination;
  final Object? data;
  const AppXReturnButton({super.key, required this.destination, this.data});

  @override
  Widget build(BuildContext context) {
    final double ctaHeight = DeviceHelper.isMobile(context) ? mobileCTAHeight : tabletAndAboveCTAHeight;
    return SizedBox(
      width: ctaHeight,
      height: ctaHeight,
      child: AppXButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            return;
          }
          navigateToPath(context, to: destination, data: data);
        },
        isLoading: false,
        // leftIconPath: AppIcons.searchBarCloseIconPath,
        removePaddings: true,
        leftIcon: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            AppIcons.backArrowIconPath,
            width: ctaHeight,
            height: ctaHeight,
          ),
        ),
        shadowColor: AppColors.borderMedium,
        bgColor: AppColors.backgroundColor,
        fgColor: AppButtonColors.secondarySurfaceDefault,
        borderColor: AppColors.borderMedium,
        hoverColor: AppButtonColors.secondarySurfaceHover,
        onPressedColor: AppButtonColors.secondarySurfacePressed,
      ),
    );
  }
}
