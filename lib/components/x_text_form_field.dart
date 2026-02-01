import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';

class AppXTextFormField extends StatefulWidget {
  const AppXTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.labelInside = false,
    this.floatingLabelBehavior,
    this.hintText = '',
    this.hintTextStyle,
    this.prefixIcon,
    this.prefixIconPath,
    this.onPrefixIconPressed,
    this.suffixIcon,
    this.suffixIconPath,
    this.onSuffixIconPressed,
    this.disabled = false,
    this.readOnly = false,
    this.obscureText = false,
    this.validator,
    this.errorMaxLines,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.fillColor = const Color(0xFFE7E5DD),
    this.minLines,
    this.maxLines,
    this.autoResize = false,
    this.borderColor = const Color(0xFFA8A8A8),
    this.enabledBorderColor = const Color(0xFFA8A8A8),
    this.disabledBorderColor = const Color(0xFFA8A8A8),
    this.focusedBorderColor = const Color(0xFF6246EA),
    // #D93025
    this.errorBorderColor = const Color(0xFFD93025),
    this.focusedErrorBorderColor = const Color(0xFFD93025),
    this.decoration,
    this.identifier = "",
    this.inputFormatters,
    this.onFocusChanged,
    this.onTap,
    this.contentPadding,
    this.maxWidth,
    this.expands = false,
    this.textAlignVertical = TextAlignVertical.center,
    this.maxLength,
    this.borderRadius = AppRadius.small,
    this.iconSize = 20.0,
    this.constraints,
    this.errorStyle,
    this.cursor = MouseCursor.defer,
  });

  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController controller;
  final String? labelText;
  final bool? labelInside;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final String hintText;
  final TextStyle? hintTextStyle;
  final Widget? prefixIcon;
  final String? prefixIconPath;
  final void Function()? onPrefixIconPressed;
  final Widget? suffixIcon;
  final String? suffixIconPath;
  final void Function()? onSuffixIconPressed;
  final bool disabled;
  final bool readOnly;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? errorMaxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final Color fillColor;
  final int? minLines;
  final int? maxLines;
  final bool autoResize;
  final Color borderColor;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color disabledBorderColor;
  final Color errorBorderColor;
  final Color focusedErrorBorderColor;
  final InputDecoration? decoration;
  final String identifier;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(bool)? onFocusChanged;
  final void Function()? onTap;
  final double? maxWidth;
  final bool expands;
  final TextAlignVertical textAlignVertical;
  final int? maxLength;
  final BorderRadius borderRadius;
  final double iconSize;
  final BoxConstraints? constraints;
  final TextStyle? errorStyle;
  final MouseCursor cursor;

  @override
  State<AppXTextFormField> createState() => _AppXTextFormFieldState();
}

class _AppXTextFormFieldState extends State<AppXTextFormField> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelInside == false) ...[
          Text(
            widget.labelText ?? '',
            style: theme.textTheme.labelMedium!.copyWith(
              color: widget.disabled ? AppButtonColors.primaryTextDisabled : AppColors.textPrimary,
            ),
          ),
          AppSpacing.spacing8_Box,
        ],
        MouseRegion(
          onEnter: (value) {
            setState(() {
              isHovering = true;
            });
          },
          onExit: (value) {
            setState(() {
              isHovering = false;
            });
          },
          cursor: widget.cursor,
          child: Semantics(
            identifier: widget.identifier,
            label: widget.identifier,
            child: Focus(
              onFocusChange: widget.onFocusChanged,
              child: TextFormField(
                textAlignVertical: widget.textAlignVertical,
                maxLength: widget.maxLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                readOnly: widget.readOnly,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: widget.disabled ? AppButtonColors.primaryTextDisabled : AppColors.textPrimary,
                ),
                focusNode: widget.focusNode,
                controller: widget.controller,
                enabled: !widget.disabled,
                obscureText: widget.obscureText,
                decoration: widget.decoration ??
                    InputDecoration(
                      isDense: true,
                      errorStyle: widget.errorStyle,
                      floatingLabelBehavior: widget.floatingLabelBehavior,
                      floatingLabelAlignment: FloatingLabelAlignment.start,
                      labelText: widget.labelInside == true ? widget.labelText : null,
                      labelStyle: theme.textTheme.labelSmall,
                      constraints: const BoxConstraints(maxWidth: 864, minWidth: 100),
                      floatingLabelStyle: theme.textTheme.labelSmall,
                      prefixIcon: widget.prefixIconPath != null
                          ? GestureDetector(
                              onTap: widget.onPrefixIconPressed,
                              child: SizedBox.square(
                                dimension: widget.iconSize,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SvgPicture.asset(
                                    widget.prefixIconPath!,
                                    fit: BoxFit.scaleDown,
                                    height: widget.iconSize,
                                    width: widget.iconSize,
                                    colorFilter: ColorFilter.mode(
                                      theme.inputDecorationTheme.prefixIconColor ?? AppColors.secondary.shade900,
                                      BlendMode.srcATop,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : widget.prefixIcon,
                      suffixIcon: widget.suffixIconPath != null
                          ? GestureDetector(
                              onTap: widget.onSuffixIconPressed,
                              child: SizedBox.square(
                                dimension: widget.iconSize,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SvgPicture.asset(
                                    widget.suffixIconPath!,
                                    fit: BoxFit.scaleDown,
                                    height: widget.iconSize,
                                    width: widget.iconSize,
                                    colorFilter: ColorFilter.mode(
                                      theme.inputDecorationTheme.suffixIconColor ?? AppColors.secondary.shade900,
                                      BlendMode.srcATop,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : widget.suffixIcon,
                      errorMaxLines: widget.errorMaxLines ?? 5,
                      hintText: widget.hintText ?? 'Placeholder',
                      hintStyle: theme.textTheme.bodyLarge?.copyWith(
                        color: AppButtonColors.primaryTextDisabled,
                        fontWeight: FontWeight.w300,
                      ),
                      filled: true,
                      fillColor: widget.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.borderColor, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.enabledBorderColor, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.focusedBorderColor, width: 1),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.disabledBorderColor, width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.errorBorderColor, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: widget.borderRadius,
                        borderSide: BorderSide(color: widget.focusedErrorBorderColor, width: 1),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacing12,
                        vertical: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) / 3 - (isMobile ? 1 : 2),
                      ),
                    ),
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onEditingComplete: widget.onEditingComplete,
                onTap: () {
                  widget.onTap?.call();
                  widget.onFocusChanged?.call(true);
                },
                onTapOutside: (_) {
                  widget.onFocusChanged?.call(false);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
