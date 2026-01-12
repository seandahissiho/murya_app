import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppDropdownV2<T> extends FormField<T> {
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool isExpanded;
  final String? label;

  AppDropdownV2({
    super.key,
    required this.items,
    T? value,
    this.onChanged,
    this.hint,
    this.isExpanded = true,
    this.label,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
  }) : super(
          initialValue: value,
          builder: (FormFieldState<T> state) {
            return _AppDropdownV2Content<T>(
              state: state,
              items: items,
              onChanged: onChanged,
              hint: hint,
              isExpanded: isExpanded,
              label: label,
            );
          },
        );
}

class _AppDropdownV2Content<T> extends StatefulWidget {
  final FormFieldState<T> state;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool isExpanded;
  final String? label;

  const _AppDropdownV2Content({
    required this.state,
    required this.items,
    this.onChanged,
    this.hint,
    required this.isExpanded,
    this.label,
  });

  @override
  State<_AppDropdownV2Content<T>> createState() =>
      _AppDropdownV2ContentState<T>();
}

class _AppDropdownV2ContentState<T> extends State<_AppDropdownV2Content<T>> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Design tokens from Figma "Input field base"
    const Color borderColor = Color(0xFFA8A8A8);
    const Color backgroundColor = Color(0xFFE7E5DD);
    const Color textColor = Color(0xFF1F1633);
    const double height = 40.0;
    const double borderRadius = 8.0;

    // Error state color
    const Color errorBorderColor = Color(0xFFFF3B30); // AppColors.errorDefault

    final bool hasError = widget.state.hasError;
    final bool isEnabled = widget.state.widget.enabled;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Safe check for infinite width to avoid DropdownButton crash
        final bool canExpand =
            widget.isExpanded && constraints.maxWidth != double.infinity;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500, // Medium usually for labels
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8), // layout/padding/md?
            ],
            Opacity(
              opacity: isEnabled ? 1.0 : 0.5,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovering = true),
                onExit: (_) => setState(() => _isHovering = false),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      color: hasError
                          ? errorBorderColor
                          : (_isHovering
                              ? const Color(0xFF1F1633)
                              : borderColor), // Darker on hover
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<T>(
                      value: widget.state.value,
                      items: widget.items,
                      onChanged: isEnabled
                          ? (T? newValue) {
                              widget.state.didChange(newValue);
                              if (widget.onChanged != null) {
                                widget.onChanged!(newValue);
                              }
                            }
                          : null,
                      isExpanded: canExpand,
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: SvgPicture.string(
                            '''<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M5 7.5L10 12.5L15 7.5" stroke="#1F1633" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''',
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF1F1633),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      hint: widget.hint != null
                          ? Text(
                              widget.hint!,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: textColor,
                                height: 20 / 14,
                              ),
                            )
                          : null,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                        height: 20 / 14,
                      ),
                      dropdownColor: backgroundColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                      focusColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                child: Text(
                  widget.state.errorText!,
                  style: const TextStyle(
                    color: errorBorderColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
