import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';

class AppXDropdown<T> extends StatefulWidget {
  const AppXDropdown({
    super.key,
    required this.controller,
    this.labelText,
    this.labelInside = false,
    this.hintText,
    this.leftIconPath,
    this.rightIconPath,
    this.rightIcon,
    this.leftIcon,
    this.size = AppXButtonSize.MEDIUM,
    this.state = AppXButtonState.ENABLED,
    this.type = AppXButtonType.PRIMARY,
    this.background = Colors.transparent,
    this.foregroundColor,
    this.borderColor,
    this.autoResize = false,
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
  final AppXButtonSize size;
  final AppXButtonState state;
  final AppXButtonType type;
  final Color background;
  final Color? foregroundColor;
  final Color? borderColor;
  final bool autoResize;
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

    return FormField(
        initialValue: widget.controller.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // autovalidateMode: AutovalidateMode.always,
        validator: (value) {
          // return 'Veuillez saisir ${widget.labelText.isNotEmpytOrNull ? "votre ${widget.labelText}" : "une donnée"}';
          if (widget.excludeNull && (value as String?)?.isEmpty != false) {
            return null;
          }
          if (value == null || (value as String).isEmpty) {
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
                    width:
                        widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
                    constraints: BoxConstraints(
                      minWidth: widget.maxDropdownWidth ??
                          theme.inputDecorationTheme.constraints?.maxWidth ??
                          double.infinity,
                      maxWidth: widget.maxDropdownWidth ??
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
                                width: widget.maxDropdownWidth ??
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
            constraints: widget.autoResize == true
                ? null
                : BoxConstraints(
                    minWidth:
                        widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
                    maxHeight: widget.maxDropdownHeight ?? double.infinity,
                    maxWidth:
                        widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
                  ),
            child: widget.child ??
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     Flexible(
                    //       child: AppXTextFormField(
                    //         maxWidth: widget.maxDropdownWidth ??
                    //             theme.inputDecorationTheme.constraints?.maxWidth ??
                    //             double.infinity,
                    //         fillColor: widget.disabled && widget.readOnly ? null : AppColors.whiteSwatch,
                    //         borderColor: widget.borderColor,
                    //         autoResize: widget.autoResize,
                    //         expands: widget.autoResize,
                    //         disabled: widget.items.isNotEmpty && !widget.disabled,
                    //         onTap: () {
                    //           // if (widget.items.isNotEmpty) {
                    //           //   return;
                    //           // }
                    //           widget.onTap?.call();
                    //         },
                    //         onEditingComplete: () {
                    //           state.didChange(widget.controller.text);
                    //         },
                    //         onChanged: (value) {
                    //           state.didChange(value);
                    //         },
                    //         onSubmitted: (value) {
                    //           state.didChange(value);
                    //         },
                    //         onFocusChanged: (hasFocus) {
                    //           if (!hasFocus) {
                    //             state.didChange(widget.controller.text);
                    //           }
                    //         },
                    //         controller: widget.controller,
                    //         decoration: widget.decoration,
                    //         constraints: widget.constraints,
                    //         labelText: widget.labelInside == null ? null : widget.labelText,
                    //         labelInside: widget.labelInside,
                    //         hintText: widget.hintTextForced
                    //             ? widget.hintText!
                    //             : "2Sélectionnez ${widget.hintText ?? "une option"}",
                    //         hintTextStyle: theme.textTheme.bodyMedium?.copyWith(
                    //           color: AppColors.textSecondary,
                    //         ),
                    //         prefixIcon: widget.leftIcon != null
                    //             ? SizedBox(
                    //                 height: 20,
                    //                 width: 20,
                    //                 child: FittedBox(
                    //                   fit: BoxFit.scaleDown,
                    //                   child: widget.leftIcon,
                    //                 ),
                    //               )
                    //             : null,
                    //         prefixIconPath: widget.leftIconPath,
                    //         suffixIcon: widget.rightIcon != null
                    //             ? SizedBox(
                    //                 height: 20,
                    //                 width: 20,
                    //                 child: FittedBox(
                    //                   fit: BoxFit.scaleDown,
                    //                   child: widget.rightIcon,
                    //                 ),
                    //               )
                    //             : null,
                    //         suffixIconPath: widget.rightIconPath,
                    //         readOnly: true,
                    //         errorMaxLines: 10,
                    //         contentPadding: widget.contentPadding ??
                    //             theme.inputDecorationTheme.contentPadding?.add(
                    //               const EdgeInsets.only(left: AppSpacing.elementMargin),
                    //             ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: AppRadius.extraLarge,
                        border: Border.all(
                          color: state.hasError
                              ? AppColors.error.shade500
                              : (widget.borderColor ?? AppColors.borderMedium),
                          width: widget.borderLineWidth,
                        ),
                      ),
                      constraints: widget.constraints ?? theme.dropdownMenuTheme.inputDecorationTheme?.constraints,
                      padding: widget.contentPadding ?? theme.dropdownMenuTheme.inputDecorationTheme?.contentPadding,
                      width: widget.maxDropdownWidth,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: (widget.autoResize || widget.maxDropdownWidth != null)
                              ? MainAxisSize.min
                              : MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              widget.controller.text.isNotEmpty
                                  ? widget.controller.text
                                  : (widget.hintTextForced
                                      ? widget.hintText!
                                      : "Sélectionnez ${widget.hintText ?? "une option"}"),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.controller.text.isNotEmpty
                                    ? (widget.foregroundColor ?? AppColors.textPrimary)
                                    : AppColors.textSecondary,
                              ),
                            ),
                            AppSpacing.elementMarginBox,
                            _dropdownIcon(context),
                          ],
                        ),
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
        });
  }

  _dropdownIcon(BuildContext context) {
    if (widget.rightIcon != null) {
      return widget.rightIcon;
    } else if (widget.rightIconPath != null) {
      if (widget.rightIconPath!.contains(".svg")) {
        return SvgPicture.asset(widget.rightIconPath!);
      } else {
        return Image.asset(
          widget.rightIconPath!,
          fit: BoxFit.contain,
        );
      }
    } else {
      return const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
        size: 24,
        opticalSize: 24,
      );
    }
  }
}

class AppTypeDropDown<T> extends StatefulWidget {
  final String label;

  // suggestionsCallback
  final Function(String search) suggestionsCallback;
  final T? selected;
  final Function(T)? onSelected;
  final double? maxDropdownWidth;
  final EdgeInsetsGeometry? contentPadding;

  const AppTypeDropDown({
    super.key,
    required this.label,
    required this.suggestionsCallback,
    this.selected,
    this.onSelected,
    this.maxDropdownWidth,
    this.contentPadding,
  });

  @override
  State<AppTypeDropDown> createState() => _AppTypeDropDownState();
}

class _AppTypeDropDownState<T> extends State<AppTypeDropDown> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      constraints: BoxConstraints(
        minWidth: widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
        maxWidth: widget.maxDropdownWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
      ),
      child: TypeAheadField<T>(
        suggestionsCallback: (search) => widget.suggestionsCallback(search),
        builder: (context, controller, focusNode) {
          return AppTextFormField(
            controller: controller,
            focusNode: focusNode,
            label: widget.label,
            // contentPadding: EdgeInsets.zero,
          );
        },
        itemBuilder: (context, client) {
          return Container();
          // return ListTile(
          //   title: Text(client.name),
          //   subtitle: Text(client.country ?? '-'),
          // );
        },
        onSelected: (item) {
          // Handle the selected client
          widget.onSelected?.call(item);
        },
      ),
    );
  }
}
