import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/helpers.dart';
import 'package:sizer/sizer.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final Function(FocusNode)? onTapOutside;
  final String? leftIcon;
  final String? rightIcon;
  final bool dynamicWidth;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.onTapOutside,
    this.leftIcon,
    this.rightIcon,
    this.dynamicWidth = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller ?? controller,
      focusNode: widget.focusNode ?? focusNode,
      enabled: widget.enabled,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        constraints: widget.dynamicWidth
            ? BoxConstraints(
                maxWidth: 100.w,
              )
            : null,
        prefixIcon: widget.leftIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: SvgPicture.asset(
                  widget.leftIcon!,
                  width: 12 * 2,
                  height: 12 * 2,
                  fit: BoxFit.scaleDown,
                  colorFilter: ColorFilter.mode(
                    AppColors.whiteSwatch.shade500,
                    BlendMode.srcATop,
                  ),
                ),
              ),
        suffixIcon: widget.rightIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: SvgPicture.asset(
                  widget.rightIcon!,
                  width: 12 * 2,
                  height: 12 * 2,
                  fit: BoxFit.scaleDown,
                  colorFilter: ColorFilter.mode(
                    AppColors.whiteSwatch.shade500,
                    BlendMode.srcATop,
                  ),
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.containerInsideMargin,
          vertical: AppSpacing.containerInsideMargin,
        ),
      ),
      onTapOutside: (event) {
        widget.focusNode!.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (widget.onTapOutside != null) {
            widget.onTapOutside!(widget.focusNode!);
          }
        });
      },
    );
  }
}

class AppTextFormField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final Function(FocusNode)? onTapOutside;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  final bool noBorder;

  // on Tap
  final Function()? onTap;

  // trailing
  final Widget? trailing;
  final double? height;
  final double? width;

  // contentPadding
  final EdgeInsetsGeometry? contentPadding;

  // onChanged
  final Function(String)? onChanged;

  // definedKey
  final GlobalKey? definedKey;
  final bool autoResize;
  final int? errorMaxLines;
  final void Function(bool)? onFocusChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final dynamic leadingIcon;

  // keyboardType
  final TextInputType keyboardType;

  const AppTextFormField({
    super.key,
    this.definedKey,
    required this.label,
    this.hintText,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.onTapOutside,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
    this.onTap,
    this.trailing,
    this.height,
    this.width,
    this.contentPadding,
    this.onChanged,
    this.autoResize = false,
    this.errorMaxLines,
    this.onFocusChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.keyboardType = TextInputType.text,
    this.noBorder = false,
    this.leadingIcon,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String initialValue = '';

  @override
  void initState() {
    initialValue = widget.controller?.text ?? controller.text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    return FormField(
      // key: UniqueKey(),
      initialValue: widget.controller?.text ?? controller.text,
      autovalidateMode: AutovalidateMode.onUnfocus,
      validator: widget.validator,
      builder: (FormFieldState<String> state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: theme.textTheme.labelMedium,
              ),
              AppSpacing.elementMarginBox,
            ],
            Stack(
              children: [
                MouseRegion(
                  cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.text,
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: widget.height ?? (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight),
                          width: widget.width,
                          child: TextFormField(
                            autocorrect: false,
                            // key: widget.key,
                            keyboardType: widget.keyboardType,
                            key: widget.definedKey,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.none,
                            inputFormatters: widget.inputFormatters,
                            controller: widget.controller ?? controller,
                            focusNode: widget.focusNode ?? focusNode,
                            enabled: widget.enabled && widget.onTap == null,
                            style: theme.textTheme.bodyMedium,
                            maxLines: widget.maxLines,
                            // validator: widget.validator,
                            decoration: InputDecoration(
                              suffixIcon: widget.trailing,
                              hintText: widget.hintText ?? 'Placeholder',
                              hintStyle: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              constraints: widget.autoResize
                                  ? theme.inputDecorationTheme.constraints?.copyWith(
                                      maxWidth: widget.width ?? 100.w,
                                    )
                                  : null,
                              // border: InputBorder.none,
                              // enabledBorder: InputBorder.none,
                              // focusedBorder: InputBorder.none,
                              // focusedErrorBorder: InputBorder.none,
                              // disabledBorder: InputBorder.none,
                              // errorBorder: InputBorder.none,
                              contentPadding: widget.contentPadding,
                              prefixIcon: widget.leadingIcon is IconData
                                  ? Icon(
                                      widget.leadingIcon,
                                      size: 20,
                                      color: AppColors.whiteSwatch.shade500,
                                    )
                                  : (widget.leadingIcon is String
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 1.0),
                                          child: SvgPicture.asset(
                                            widget.leadingIcon,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.scaleDown,
                                            colorFilter: const ColorFilter.mode(
                                              AppColors.textTertiary,
                                              BlendMode.srcATop,
                                            ),
                                          ),
                                        )
                                      : null),
                            ),
                            onTap: () {
                              state.didChange(widget.controller?.text ?? controller.text);
                              initialValue = widget.controller?.text ?? controller.text;
                              setState(() {});
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (widget.onFocusChanged != null) {
                                  widget.onFocusChanged!(true);
                                }
                              });
                            },
                            onTapOutside: (event) {
                              state.didChange(widget.controller?.text ?? controller.text);
                              initialValue = widget.controller?.text ?? controller.text;
                              setState(() {});
                              (widget.focusNode ?? focusNode).unfocus();
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (widget.onTapOutside != null) {
                                  widget.onTapOutside!(widget.focusNode ?? focusNode);
                                }
                              });
                            },
                            onChanged: (value) {
                              // initialValue = value;
                              state.didChange(value);
                              widget.onChanged?.call(value);
                            },
                            onFieldSubmitted: state.didChange,
                          ),
                        ),
                        if (widget.onTap != null)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.enabled == false)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primaryDisabled,
                        borderRadius: AppRadius.borderRadius20,
                      ),
                    ),
                  )
              ],
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
        );
      },
    );
  }
}

class PhoneTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final void Function(bool)? onFocusChanged;
  final bool excluedNull;
  final String? hintText;
  final bool disabled;

  const PhoneTextFormField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onFocusChanged,
    this.excluedNull = false,
    this.hintText,
    this.disabled = false,
  });

  @override
  State<PhoneTextFormField> createState() => _PhoneTextFormFieldState();
}

class _PhoneTextFormFieldState extends State<PhoneTextFormField> {
  bool _phoneNumberIsInvalid = false;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      enabled: !widget.disabled,
      label: "Numéro de téléphone",
      controller: widget.controller,
      hintText: widget.hintText ?? "Entrez le numéro de téléphone",
      // contentPadding: theme.inputDecorationTheme.contentPadding?.add(
      //   const EdgeInsets.only(left: AppSpacing.containerInsideMargin),
      // ),
      onChanged: widget.onChanged,
      onFocusChanged: (value) async {
        if (value == false) {
          // Add +33 to the phone number if it starts with 06 or 07 for France
          if (widget.controller.text.isNotEmpty &&
              widget.controller.text.length == 10 &&
              (widget.controller.text.startsWith("06") || widget.controller.text.startsWith("07"))) {
            widget.controller.text = "+33${widget.controller.text.substring(1)}";
          }
          widget.onFocusChanged?.call(value);
          if (widget.controller.text.noWhiteSpace().isEmpty) {
            _phoneNumberIsInvalid = false;
            setState(() {});
            return;
          }
          widget.controller.text = widget.controller.text.noWhiteSpace();
          _phoneNumberIsInvalid = !(await isValidPhoneNumber(widget.controller.text));
          setState(() {});
        }
      },
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      errorMaxLines: 10,
      validator: (value) {
        if (widget.excluedNull && value?.isEmpty != false) {
          return null;
        }
        if ((value == null || value.isEmpty)) {
          return 'Veuillez saisir votre numéro de téléphone';
        }
        if (_phoneNumberIsInvalid) {
          return 'Veuillez saisir un numéro de téléphone valide';
        }
        return null;
      },
    );
  }
}
