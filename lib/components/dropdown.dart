import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';

class AppXDropdown<T> extends StatefulWidget {
  const AppXDropdown({
    super.key,
    required this.controller,
    this.labelText,
    this.labelInside = false,
    this.hintText,
    this.leftIconPath,
    this.rightIconPath = AppIcons.angleDownPath,
    this.rightIcon,
    this.leftIcon,
    this.bgColor = const Color(0xFFE7E5DD),
    this.fgColor,
    this.borderColor,
    this.shrinkWrap = false,
    this.borderLineWidth = 1,
    this.removePaddings = false,
    this.horizontalAlignment = MainAxisAlignment.center,
    this.onSelected,
    required this.items,
    this.maxDropdownWidth,
    this.maxDropdownHeight = 400,
    this.excludeNull = false,
    this.hintTextForced = false,
    this.contentPadding,
    this.child,
    this.disabled = false,
    this.readOnly = false,
    this.decoration,
    this.constraints,
    this.tooltipMessage,
    this.onTap,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? leftIconPath;
  final String? rightIconPath;
  final Widget? rightIcon;
  final Widget? leftIcon;
  final Color bgColor;
  final Color? fgColor;
  final Color? borderColor;
  final bool shrinkWrap;
  final double borderLineWidth;
  final bool removePaddings;
  final MainAxisAlignment horizontalAlignment;
  final Function(T?)? onSelected;
  final Iterable<DropdownMenuEntry<T?>> items;
  final double? maxDropdownWidth;
  final double? maxDropdownHeight;
  final bool excludeNull;
  final bool hintTextForced;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? child;
  final bool disabled;
  final bool readOnly;
  final InputDecoration? decoration;
  final BoxConstraints? constraints;
  final String? tooltipMessage;
  final Function()? onTap;
  final bool? labelInside;

  @override
  State<AppXDropdown<T>> createState() => _AppXDropdownState<T>();
}

class _AppXDropdownState<T> extends State<AppXDropdown<T>> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _anchorKey = GlobalKey();

  static const double itemHeight = 40;

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    final bool showTooltip = widget.tooltipMessage?.isNotEmpty == true;
    final double? shrinkWrapWidth = _calculateShrinkWrapWidth(
      theme,
      Directionality.of(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelInside == false && widget.labelText != null && widget.labelText!.isNotEmpty) ...[
          Text(
            widget.labelText ?? '',
            style: theme.textTheme.labelMedium!.copyWith(
              color: widget.disabled ? AppButtonColors.primaryTextDisabled : AppColors.textPrimary,
            ),
          ),
          AppSpacing.spacing8_Box,
        ],
        SizedBox(
          height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          child: FormField(
              initialValue: widget.controller.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (widget.excludeNull && (value)?.isEmpty != false) {
                  return null;
                }
                if (value == null || (value).isEmpty) {
                  return 'Veuillez saisir ${widget.labelText.isNotEmptyOrNull ? "votre ${widget.labelText}" : "une donnée"}';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      key: _anchorKey,
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (widget.disabled || widget.readOnly) {
                          return;
                        }
                        if (widget.onTap != null) {
                          widget.onTap!();
                          return;
                        }
                        FocusScope.of(context).unfocus();
                        if (!mounted || !context.mounted) return;
                        await _showMenuAnchored(
                          context: context,
                          theme: theme,
                          isMobile: isMobile,
                          state: state,
                          shrinkWrapWidth: shrinkWrapWidth,
                        );
                      },
                      child: widget.child ?? _defaultChild(theme, isMobile, state),
                    ),
                    if (state.hasError) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.spacing8, left: AppSpacing.spacing8),
                        child: Text(
                          state.errorText ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error.shade500,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
        ),
      ],
    );
  }

  double? _calculateShrinkWrapWidth(ThemeData theme, TextDirection textDirection) {
    if (!widget.shrinkWrap || widget.items.isEmpty) {
      return null;
    }

    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.primary.shade900,
    );
    double maxWidth = 175;

    for (final item in widget.items) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: textStyle,
        ),
        textDirection: textDirection,
        maxLines: 1,
      )..layout();

      double itemWidth = painter.width + (AppSpacing.spacing4 * 2.5);
      if (item.leadingIcon != null) {
        itemWidth += 14 + AppSpacing.spacing8;
      }
      if (itemWidth > maxWidth) {
        maxWidth = itemWidth;
      }
    }

    if (widget.maxDropdownWidth != null) {
      maxWidth = maxWidth.clamp(0, widget.maxDropdownWidth!);
    }

    return maxWidth == 0 ? null : maxWidth;
  }

  _dropdownIcon(BuildContext context) {
    final isMobile = DeviceHelper.isMobile(context);
    if (widget.rightIcon != null) {
      return widget.rightIcon;
    } else if (widget.rightIconPath != null) {
      if (widget.rightIconPath!.contains(".svg")) {
        return SizedBox(
          height: isMobile ? 20 : 24,
          width: isMobile ? 20 : 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SvgPicture.asset(
              widget.rightIconPath!,
              height: isMobile ? 20 : 24,
              width: isMobile ? 20 : 24,
              colorFilter: ColorFilter.mode(
                widget.disabled ? AppButtonColors.primaryTextDisabled : AppColors.textPrimary,
                BlendMode.srcATop,
              ),
            ),
          ),
        );
      } else {
        return Image.asset(
          widget.rightIconPath!,
          fit: BoxFit.contain,
        );
      }
    } else {
      return Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
        size: (isMobile ? 18 : 20),
        opticalSize: (isMobile ? 18 : 20),
      );
    }
  }

  _defaultChild(ThemeData theme, bool isMobile, FormFieldState<String> state) {
    return Container(
      height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
      decoration: BoxDecoration(
        color: widget.bgColor, // Colors.transparent,
        borderRadius: AppRadius.small,
        border: Border.all(
          color: state.hasError ? AppColors.error.shade500 : (widget.borderColor ?? AppColors.borderMedium),
          width: widget.borderLineWidth,
        ),
      ),
      // constraints: widget.constraints ?? theme.dropdownMenuTheme.inputDecorationTheme?.constraints,
      padding: widget.contentPadding ?? theme.dropdownMenuTheme.inputDecorationTheme?.contentPadding,
      width: widget.maxDropdownWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedWidth = constraints.maxWidth.isFinite;
          final textWidget = Text(
            widget.controller.text.isNotEmpty
                ? widget.controller.text
                : (widget.hintTextForced ? widget.hintText! : "Sélectionnez ${widget.hintText ?? "une option"}"),
            style: (isMobile ? theme.textTheme.labelSmall : theme.textTheme.bodyMedium)?.copyWith(
              color: widget.disabled
                  ? AppButtonColors.primaryTextDisabled
                  : widget.controller.text.isNotEmpty
                      ? (widget.fgColor ?? AppColors.textPrimary)
                      : AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

          return Row(
            mainAxisSize: (widget.shrinkWrap || !hasBoundedWidth) ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.leftIcon != null || widget.leftIconPath != null) ...[
                widget.leftIcon ?? SvgPicture.asset(widget.leftIconPath!),
                const SizedBox(width: AppSpacing.spacing8),
              ],
              if (widget.shrinkWrap || !hasBoundedWidth) textWidget else Expanded(child: textWidget),
              if (widget.shrinkWrap) AppSpacing.spacing8_Box,
              if (!widget.shrinkWrap) const SizedBox(width: AppSpacing.spacing8),
              _dropdownIcon(context),
            ],
          );
        },
      ),
    );
  }

  Future<T?> _showMenuAnchored({
    required BuildContext context,
    required ThemeData theme,
    required bool isMobile,
    required FormFieldState<String> state,
    required double? shrinkWrapWidth,
  }) async {
    final appSize = AppSize(context);

    final renderObject = _anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return null;

    final box = renderObject;
    final Offset topLeft = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final double fieldW = size.width;
    final double menuW = widget.maxDropdownWidth ?? (widget.shrinkWrap ? (shrinkWrapWidth ?? fieldW) : fieldW);

    final double menuMaxH = widget.maxDropdownHeight ?? 400;

    // Estimation simple de la hauteur réelle du menu (nb items * itemHeight, capé)
    final double itemH = isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight;
    final double desiredMenuH = (widget.items.length * itemH).clamp(0, menuMaxH);

    // Espace dispo dessous / dessus
    final double spaceBelow = appSize.screenHeight - (topLeft.dy + size.height);
    final double spaceAbove = topLeft.dy;

    // Décide : dessous si ça rentre, sinon au-dessus si ça rentre, sinon côté le plus grand
    final bool openBelow;
    if (spaceBelow >= desiredMenuH) {
      openBelow = true;
    } else if (spaceAbove >= desiredMenuH) {
      openBelow = false;
    } else {
      openBelow = spaceBelow >= spaceAbove;
    }

    final double left = topLeft.dx;
    final double top = openBelow ? (topLeft.dy + size.height) : (topLeft.dy - desiredMenuH);

    // Clamp pour éviter de sortir de l’écran
    final double clampedLeft = left.clamp(0.0, (appSize.screenWidth - menuW).clamp(0.0, double.infinity));
    final double clampedTop = top.clamp(0.0, (appSize.screenHeight - 8).clamp(0.0, double.infinity));

    // RelativeRect: left/top + right/bottom calculés
    final position = RelativeRect.fromLTRB(
      clampedLeft,
      clampedTop,
      appSize.screenWidth - (clampedLeft + menuW),
      appSize.screenHeight - clampedTop,
    );

    return await showMenu<T>(
      context: context,
      color: AppColors.backgroundColor,
      constraints: BoxConstraints(
        minWidth: menuW,
        maxWidth: menuW,
        maxHeight: menuMaxH,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.small,
        side: BorderSide(
          color: AppColors.borderLight,
          width: widget.borderLineWidth,
        ),
      ),
      position: position,
      items: widget.items.map((item) {
        return PopupMenuItem<T>(
          value: item.value as T?,
          height: itemH,
          child: Row(
            children: [
              if (item.leadingIcon != null) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: FittedBox(fit: BoxFit.contain, child: item.leadingIcon!),
                ),
                const SizedBox(width: AppSpacing.spacing8),
              ],
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary.shade900,
                  ),
                ),
              ),
              if (item.trailingIcon != null) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: FittedBox(fit: BoxFit.contain, child: item.trailingIcon!),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value == null) return null;

      final selected = widget.items.firstWhere((e) => e.value == value);
      widget.controller.text = selected.label;
      widget.onSelected?.call(value);
      state.didChange(widget.controller.text);
      if (mounted) setState(() {});
      return value;
    });
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';

class AppXDropdown<T> extends StatefulWidget {
  const AppXDropdown({
    super.key,
    required this.controller,
    this.labelText,
    this.labelInside = false,
    this.hintText,
    this.leftIconPath,
    this.rightIconPath = AppIcons.angleDownPath,
    this.rightIcon,
    this.leftIcon,
    this.background = Colors.transparent,
    this.foregroundColor,
    this.borderColor,
    this.shrinkWrap = false,
    this.borderLineWidth = 1,
    this.removePaddings = false,
    this.horizontalAlignment = MainAxisAlignment.center,
    this.onSelected,
    required this.items,
    this.maxDropdownWidth,
    this.maxDropdownHeight = 400,
    this.excludeNull = false,
    this.hintTextForced = false,
    this.contentPadding,
    this.child,
    this.disabled = false,
    this.readOnly = false,
    this.decoration,
    this.constraints,
    this.tooltipMessage,
    this.onTap,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? leftIconPath;
  final String? rightIconPath;
  final Widget? rightIcon;
  final Widget? leftIcon;
  final Color background;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool shrinkWrap;
  final double borderLineWidth;
  final bool removePaddings;
  final MainAxisAlignment horizontalAlignment;
  final Function(T?)? onSelected;
  final Iterable<DropdownMenuEntry<T?>> items;
  final double? maxDropdownWidth;
  final double? maxDropdownHeight;
  final bool excludeNull;
  final bool hintTextForced;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? child;
  final bool disabled;
  final bool readOnly;
  final InputDecoration? decoration;
  final BoxConstraints? constraints;
  final String? tooltipMessage;
  final Function()? onTap;
  final bool? labelInside;

  @override
  State<AppXDropdown<T>> createState() => _AppXDropdownState<T>();
}

class _AppXDropdownState<T> extends State<AppXDropdown<T>> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _menuFocusNode = FocusNode(debugLabel: 'AppXDropdownMenuFocus');
  final FocusNode _childFocusNode = FocusNode(debugLabel: 'AppXDropdownAnchorFocus');
  final MenuController _menuController = MenuController(); // ✅ persistant

  static const double itemHeight = 40;

  @override
  void dispose() {
    _childFocusNode.dispose();
    _menuFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = DeviceHelper.isMobile(context);
    final showTooltip = widget.tooltipMessage?.isNotEmpty == true;

    return LayoutBuilder(
      builder: (context, c) {
        final shrinkWrapWidth = _calculateShrinkWrapWidth(theme, Directionality.of(context));

        // Largeur "field" (anchor)
        final double fieldW = widget.maxDropdownWidth ?? (c.maxWidth.isFinite ? c.maxWidth : (shrinkWrapWidth ?? 180));

        // Largeur "menu" (dropdown)
        final double menuW = widget.shrinkWrap ? (shrinkWrapWidth ?? fieldW) : fieldW;

        final menuStyle = MenuStyle(
          // Fond + padding + border/shape du panel du menu
          backgroundColor: MaterialStatePropertyAll(AppColors.blackSwatch),
          padding: const MaterialStatePropertyAll(EdgeInsets.zero),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: AppRadius.small,
              side: BorderSide(
                color: AppColors.primary,
                width: widget.borderLineWidth,
              ),
            ),
          ),
          // Optionnel: tu peux aussi régler l'élévation
          elevation: const MaterialStatePropertyAll(1),
        );

        return SizedBox(
          height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          child: FormField<String>(
            initialValue: widget.controller.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (widget.excludeNull && (value)?.isEmpty != false) return null;
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir ${widget.labelText.isNotEmptyOrNull ? "votre ${widget.labelText}" : "une donnée"}';
              }
              return null;
            },
            builder: (state) {
              final anchorChild = widget.child ?? _buildField(theme, isMobile, fieldW, state);

              return TooltipVisibility(
                visible: showTooltip,
                child: Tooltip(
                  message: showTooltip ? widget.tooltipMessage! : '',
                  child: MenuAnchor(
                    controller: _menuController,
                    childFocusNode: _childFocusNode,
                    style: menuStyle,
                    alignmentOffset: const Offset(0, 8),
                    crossAxisUnconstrained: false,
                    onOpen: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!_menuFocusNode.hasFocus) _menuFocusNode.requestFocus();
                      });
                    },
                    // Le menu (panel) : on force une largeur exacte + hauteur max + scroll.
                    menuChildren: <Widget>[
                      SizedBox(
                        width: menuW,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: widget.maxDropdownHeight ?? 400,
                          ),
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: KeyboardListener(
                              focusNode: _menuFocusNode,
                              autofocus: true,
                              onKeyEvent: (event) {
                                final key = event.logicalKey;
                                if (key == LogicalKeyboardKey.arrowDown) {
                                  _scrollController.animateTo(
                                    _scrollController.offset + itemHeight,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                  );
                                } else if (key == LogicalKeyboardKey.arrowUp) {
                                  _scrollController.animateTo(
                                    _scrollController.offset - itemHeight,
                                    duration: const Duration(milliseconds: 120),
                                    curve: Curves.easeOut,
                                  );
                                } else if (key == LogicalKeyboardKey.pageDown) {
                                  _scrollController.animateTo(
                                    _scrollController.offset + (itemHeight * 6),
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOut,
                                  );
                                } else if (key == LogicalKeyboardKey.pageUp) {
                                  _scrollController.animateTo(
                                    _scrollController.offset - (itemHeight * 6),
                                    duration: const Duration(milliseconds: 160),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.items.map((item) {
                                    final bool isLast = item == widget.items.last;

                                    return InkWell(
                                      onTap: (widget.disabled || widget.readOnly)
                                          ? null
                                          : () {
                                              if (_menuController.isOpen) _menuController.close();

                                              Future.microtask(() {
                                                widget.controller.text = item.label;
                                                widget.onSelected?.call(item.value);
                                                state.didChange(widget.controller.text);
                                                if (mounted) setState(() {});
                                              });
                                            },
                                      child: Container(
                                        height: itemHeight,
                                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.tinyMargin),
                                        decoration: BoxDecoration(
                                          color: AppColors.blackSwatch,
                                          border: Border(
                                            bottom: BorderSide(
                                              color: isLast
                                                  ? Colors.transparent
                                                  : AppColors.primary.shade900.withAlpha(15),
                                              width: widget.borderLineWidth,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            if (item.leadingIcon != null) ...[
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: item.leadingIcon!,
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.elementMargin),
                                            ],
                                            Expanded(
                                              child: Text(
                                                item.label,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: AppColors.primary.shade900,
                                                ),
                                              ),
                                            ),
                                            if (item.trailingIcon != null) ...[
                                              SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: item.trailingIcon!,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Le "bouton" (anchor)
                    builder: (context, controller, child) {
                      return InkWell(
                        onTap: (widget.disabled || widget.readOnly)
                            ? null
                            : () {
                                widget.onTap?.call();
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                        child: child!,
                      );
                    },
                    child: anchorChild,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildField(ThemeData theme, bool isMobile, double? width, FormFieldState<String> state) {
    final text = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : (widget.hintTextForced ? (widget.hintText ?? '') : "Sélectionnez ${widget.hintText ?? "une option"}");

    final textStyle = (isMobile ? theme.textTheme.labelSmall : theme.textTheme.bodyMedium)?.copyWith(
      color: widget.controller.text.isNotEmpty
          ? (widget.foregroundColor ?? AppColors.textPrimary)
          : AppColors.textSecondary,
    );

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
          width: width,
          padding: widget.contentPadding ?? theme.dropdownMenuTheme.inputDecorationTheme?.contentPadding,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: AppRadius.small,
            border: Border.all(
              color: state.hasError ? AppColors.error.shade500 : (widget.borderColor ?? AppColors.borderMedium),
              width: widget.borderLineWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (widget.leftIcon != null || widget.leftIconPath != null) ...[
                widget.leftIcon ?? SvgPicture.asset(widget.leftIconPath!),
                const SizedBox(width: AppSpacing.elementMargin),
              ],
              Expanded(
                child: Text(
                  text,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.elementMargin),
              _dropdownIcon(context),
            ],
          ),
        ),
        if (state.hasError) ...[
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.elementMargin, left: AppSpacing.elementMargin),
            child: Text(
              state.errorText ?? '',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error.shade500),
            ),
          ),
        ],
      ],
    );
  }

  double? _calculateShrinkWrapWidth(ThemeData theme, TextDirection textDirection) {
    if (!widget.shrinkWrap || widget.items.isEmpty) return null;

    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.primary.shade900,
    );

    double maxWidth = 175;

    for (final item in widget.items) {
      final painter = TextPainter(
        text: TextSpan(text: item.label, style: textStyle),
        textDirection: textDirection,
        maxLines: 1,
      )..layout();

      double itemWidth = painter.width + (AppSpacing.tinyMargin * 2.5);
      if (item.leadingIcon != null) itemWidth += 14 + AppSpacing.elementMargin;
      if (itemWidth > maxWidth) maxWidth = itemWidth;
    }

    if (widget.maxDropdownWidth != null) {
      maxWidth = maxWidth.clamp(0, widget.maxDropdownWidth!);
    }

    return maxWidth == 0 ? null : maxWidth;
  }

  Widget _dropdownIcon(BuildContext context) {
    final isMobile = DeviceHelper.isMobile(context);
    if (widget.rightIcon != null) {
      return widget.rightIcon!;
    } else if (widget.rightIconPath != null) {
      if (widget.rightIconPath!.contains(".svg")) {
        return SizedBox(
          height: isMobile ? 20 : 24,
          width: isMobile ? 20 : 24,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SvgPicture.asset(
              widget.rightIconPath!,
              height: isMobile ? 20 : 24,
              width: isMobile ? 20 : 24,
            ),
          ),
        );
      }
      return Image.asset(widget.rightIconPath!, fit: BoxFit.contain);
    }

    return Icon(
      Icons.keyboard_arrow_down,
      color: AppColors.textSecondary,
      size: isMobile ? 18 : 20,
      opticalSize: isMobile ? 18 : 20,
    );
  }
}

 */
