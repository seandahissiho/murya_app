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
    this.rightIconPath = AppIcons.chevronDownPixelPath,
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
  final FocusNode _focusNode = FocusNode();

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
    final double? shrinkWrapWidth = _calculateShrinkWrapWidth(
      theme,
      Directionality.of(context),
    );

    return SizedBox(
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
            return PopupMenuButton<T>(
              enabled: !widget.disabled,
              tooltip: widget.tooltipMessage,
              elevation: 1,
              color: AppColors.backgroundColor,
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<T>(
                    enabled: false,
                    // Disable the item to prevent default tap behavior
                    child: Container(
                      color: Colors.transparent,
                      // width: (widget.maxDropdownWidth ??
                      //     theme.inputDecorationTheme.constraints?.maxWidth ??
                      //     double.infinity),
                      constraints: BoxConstraints(
                        minWidth: widget.shrinkWrap
                            ? (shrinkWrapWidth ?? 10)
                            : widget.maxDropdownWidth ??
                                theme.inputDecorationTheme.constraints?.maxWidth ??
                                double.infinity,
                        maxWidth: widget.shrinkWrap
                            ? (shrinkWrapWidth ??
                                widget.maxDropdownWidth ??
                                theme.inputDecorationTheme.constraints?.maxWidth ??
                                double.infinity)
                            : widget.maxDropdownWidth ??
                                theme.inputDecorationTheme.constraints?.maxWidth ??
                                double.infinity,
                        maxHeight: widget.maxDropdownHeight ?? double.infinity,
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thickness: AppSpacing.elementMargin / 1.5,
                        radius: const Radius.circular(AppRadius.largeRadius),
                        trackVisibility: false,
                        thumbVisibility: true,
                        child: KeyboardListener(
                          focusNode: _focusNode,
                          autofocus: true,
                          onKeyEvent: (event) {
                            // Handle keyboard events
                            final key = event.logicalKey;
                            if (key == LogicalKeyboardKey.arrowDown) {
                              // Move down by one item
                              _scrollController.animateTo(
                                _scrollController.offset + itemHeight,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            } else if (key == LogicalKeyboardKey.arrowUp) {
                              // Move up by one item
                              _scrollController.animateTo(
                                _scrollController.offset - itemHeight,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            } else if (key == LogicalKeyboardKey.pageDown) {
                              // Page down: scroll by a larger chunk
                              _scrollController.animateTo(
                                _scrollController.offset + (itemHeight * 5),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            } else if (key == LogicalKeyboardKey.pageUp) {
                              // Page up
                              _scrollController.animateTo(
                                _scrollController.offset - (itemHeight * 5),
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // For alphanumeric keys, you could jump to the first matching item
                              // Example:
                              if (event.character != null) {
                                String inputChar = event.character!.toLowerCase();
                                int index = widget.items
                                        .indexWhereOrNull((item) => item.label.toLowerCase().startsWith(inputChar)) ??
                                    -1;
                                if (index != -1) {
                                  _scrollController.animateTo(
                                    index * itemHeight,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            }
                          },
                          child: ListView(
                            controller: _scrollController,
                            shrinkWrap: true,
                            children: widget.items.map((item) {
                              return InkWell(
                                onTap: () {
                                  widget.controller.text = item.label;
                                  widget.onSelected?.call(item.value);
                                  state.didChange(widget.controller.text);
                                  Navigator.pop(context, item.value);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    // add bottom border to each item except the last one
                                    border: Border(
                                      bottom: BorderSide(
                                        color: item == widget.items.last
                                            ? Colors.transparent
                                            : AppColors.primary.shade900.withAlpha(15),
                                        width: widget.borderLineWidth,
                                      ),
                                    ),
                                  ),
                                  width: widget.shrinkWrap
                                      ? (shrinkWrapWidth ??
                                          widget.maxDropdownWidth ??
                                          theme.inputDecorationTheme.constraints?.maxWidth ??
                                          double.infinity)
                                      : widget.maxDropdownWidth ??
                                          theme.inputDecorationTheme.constraints?.maxWidth ??
                                          double.infinity,
                                  height: itemHeight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.tinyMargin,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
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
                                      Flexible(
                                        child: Text(
                                          item.label,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: AppColors.primary.shade900,
                                          ),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
                ];
              },
              onSelected: (value) {
                String result = widget.items.firstWhere((element) => element.value == value).label;
                widget.controller.text = result.toString();
                widget.onSelected?.call(value);
                state.didChange(widget.controller.text);
                setState(() {
                  // Update the state to reflect the selected value
                });
                // Navigator.pop(context);
              },
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.small,
                side: BorderSide(
                  color: AppColors.primary,
                  width: widget.borderLineWidth,
                ),
              ),
              offset: const Offset(0, 40 * 1.2),
              padding: EdgeInsets.zero,
              onOpened: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                  }
                });
              },
              constraints: widget.shrinkWrap == true
                  ? null
                  : BoxConstraints(
                      minHeight: tabletAndAboveCTAHeight,
                      minWidth: widget.maxDropdownWidth ??
                          theme.inputDecorationTheme.constraints?.maxWidth ??
                          double.infinity,
                      maxHeight: widget.maxDropdownHeight ?? double.infinity,
                      maxWidth: widget.maxDropdownWidth ??
                          theme.inputDecorationTheme.constraints?.maxWidth ??
                          double.infinity,
                    ),
              child: widget.child ??
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: AppRadius.small,
                          border: Border.all(
                            color: state.hasError
                                ? AppColors.error.shade500
                                : (widget.borderColor ?? AppColors.borderMedium),
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
                                  : (widget.hintTextForced
                                      ? widget.hintText!
                                      : "Sélectionnez ${widget.hintText ?? "une option"}"),
                              style: (isMobile ? theme.textTheme.labelSmall : theme.textTheme.bodyMedium)?.copyWith(
                                color: widget.controller.text.isNotEmpty
                                    ? (widget.foregroundColor ?? AppColors.primaryDefault)
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );

                            return Row(
                              mainAxisSize:
                                  (widget.shrinkWrap || !hasBoundedWidth) ? MainAxisSize.min : MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (widget.leftIcon != null || widget.leftIconPath != null) ...[
                                  widget.leftIcon ?? SvgPicture.asset(widget.leftIconPath!),
                                  const SizedBox(width: AppSpacing.elementMargin),
                                ],
                                if (widget.shrinkWrap || !hasBoundedWidth) textWidget else Expanded(child: textWidget),
                                if (widget.shrinkWrap) AppSpacing.elementMarginBox,
                                if (!widget.shrinkWrap) const SizedBox(width: AppSpacing.elementMargin),
                                _dropdownIcon(context),
                              ],
                            );
                          },
                        ),
                      ),
                      if (state.hasError) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.elementMargin, left: AppSpacing.elementMargin),
                          child: Text(
                            state.errorText ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error.shade500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
            );
          }),
    );
  }

  double? _calculateShrinkWrapWidth(ThemeData theme, TextDirection textDirection) {
    if (!widget.shrinkWrap || widget.items.isEmpty) {
      return null;
    }

    final TextStyle? textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.primary.shade900,
    );
    double maxWidth = 0;

    for (final item in widget.items) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: item.label,
          style: textStyle,
        ),
        textDirection: textDirection,
        maxLines: 1,
      )..layout();

      double itemWidth = painter.width + (AppSpacing.tinyMargin * 2.5);
      if (item.leadingIcon != null) {
        itemWidth += 14 + AppSpacing.elementMargin;
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
          height: isMobile ? 12 : 14,
          width: isMobile ? 12 : 14,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SvgPicture.asset(
              widget.rightIconPath!,
              height: isMobile ? 12 : 14,
              width: isMobile ? 12 : 14,
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
}

// class AppTypeDropDown<T> extends StatefulWidget {
//   final String label;
//
//   // suggestionsCallback
//   final Function(String search) suggestionsCallback;
//   final T? selected;
//   final Function(T)? onSelected;
//   final double? maxDropdownWidth;
//   final EdgeInsetsGeometry? contentPadding;
//
//   const AppTypeDropDown({
//     super.key,
//     required this.label,
//     required this.suggestionsCallback,
//     this.selected,
//     this.onSelected,
//     this.maxDropdownWidth,
//     this.contentPadding,
//   });
//
//   @override
//   State<AppTypeDropDown> createState() => _AppTypeDropDownState();
// }

// class _AppTypeDropDownState<T> extends State<AppTypeDropDown> {
//   @override
//   Widget build(BuildContext context) {
//     final ThemeData theme = Theme.of(context);
//     return Container(
//       constraints: BoxConstraints(
//         minWidth: widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
//         maxWidth: widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
//       ),
//       child: TypeAheadField<T>(
//         suggestionsCallback: (search) => widget.suggestionsCallback(search),
//         builder: (context, controller, focusNode) {
//           return AppTextFormField(
//             controller: controller,
//             focusNode: focusNode,
//             label: widget.label,
//             // contentPadding: EdgeInsets.zero,
//           );
//         },
//         itemBuilder: (context, client) {
//           return Container();
//           // return ListTile(
//           //   title: Text(client.name),
//           //   subtitle: Text(client.country ?? '-'),
//           // );
//         },
//         onSelected: (item) {
//           // Handle the selected client
//           widget.onSelected?.call(item);
//         },
//       ),
//     );
//   }
// }
