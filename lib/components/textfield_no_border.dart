import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:murya/config/DS.dart';

class NoBorderTextField extends StatefulWidget {
  final String hint;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final String? Function(String?)? validator;
  final GlobalKey? definedKey;
  //             onTapOutside: (event) {
  //               // Close the keyboard when tapping outside
  //               FocusScope.of(context).unfocus();
  //             },
  //             onFocusChanged: (value) {
  //               if (value == true) {
  //                 // auto launch search when focusing
  //                 _suggestionsController.refresh();
  //               }
  //             },
  final Function(FocusNode)? onTapOutside;
  final void Function(bool)? onFocusChanged;

  const NoBorderTextField({
    super.key,
    this.definedKey,
    required this.hint,
    required this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.validator,
    this.onTapOutside,
    this.onFocusChanged,
  });

  @override
  State<NoBorderTextField> createState() => _NoBorderTextFieldState();
}

class _NoBorderTextFieldState extends State<NoBorderTextField> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    (widget.focusNode ?? focusNode).addListener(() {
      // if the focus changes, call the onChanged callback
      if (!(widget.focusNode?.hasFocus ?? focusNode.hasFocus)) {
        widget.onChanged?.call(widget.controller?.text ?? controller.text);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return FormField(
        // key: UniqueKey(),
        initialValue: widget.controller?.text ?? controller.text,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: widget.validator,
        builder: (FormFieldState<String> state) {
          return Container(
            height: 36,
            color: state.hasError
                ? Colors.red.withAlpha(62)
                : (widget.enabled ? Colors.transparent : AppColors.primaryDisabled),
            // color: Colors.yellow,
            // width: measureTextWidth("000000000000000000000000000000000000", theme.textTheme.bodyMedium!),
            padding: const EdgeInsets.only(bottom: 4),
            child: Theme(
              data: ThemeData(),
              child: TextFormField(
                key: widget.definedKey,
                enabled: widget.enabled,
                controller: widget.controller ?? controller,
                focusNode: widget.focusNode ?? focusNode,
                keyboardType: widget.keyboardType,
                onTapOutside: (event) {
                  focusNode.unfocus();
                  // unfocus the text field when tapping outside
                  FocusScope.of(context).requestFocus(FocusNode());
                  Future.delayed(const Duration(milliseconds: 100), () {
                    // delay to ensure the text field is unfocused before calling onChanged
                    state.didChange(widget.controller?.text ?? controller.text);
                    widget.onChanged?.call(widget.controller?.text ?? controller.text);
                    widget.onSubmitted?.call(widget.controller?.text ?? controller.text);
                    widget.onTapOutside?.call(widget.focusNode ?? focusNode);
                  });
                },
                onTap: () {
                  state.didChange(widget.controller?.text ?? controller.text);
                  setState(() {});
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (widget.onFocusChanged != null) {
                      widget.onFocusChanged!(true);
                    }
                  });
                },
                onEditingComplete: () {
                  state.didChange(widget.controller?.text ?? controller.text);
                  widget.onChanged?.call(widget.controller?.text ?? controller.text);
                  widget.onSubmitted?.call(widget.controller?.text ?? controller.text);
                },
                onFieldSubmitted: (String value) {
                  state.didChange(value);
                  widget.onChanged?.call(value);
                  widget.onSubmitted?.call(value);
                },
                onSaved: (String? value) {
                  state.didChange(value);
                  widget.onChanged?.call(value ?? '');
                  widget.onSubmitted?.call(value ?? '');
                },
                onChanged: (String value) {
                  state.didChange(value);
                  widget.onChanged?.call(value);
                },
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
                inputFormatters: [
                  if (widget.keyboardType == TextInputType.number) ...[
                    // Allow only digits, no negative sign, and no decimal point, limit to 5 digits
                    FilteringTextInputFormatter.digitsOnly,
                    //limit to 5 digits
                    LengthLimitingTextInputFormatter(6),
                  ],
                  if (widget.keyboardType == TextInputType.text) ...[
                    LengthLimitingTextInputFormatter(50),
                  ],
                ],
                // validator: widget.validator,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.whiteSwatch.shade500,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,

                  // contentPadding: EdgeInsets.only(
                  //   left: AppSpacing.sectionMargin,
                  //   bottom: AppSpacing.groupMargin / 2,
                  // ),
                  // constraints: const BoxConstraints(
                  //   maxHeight: double.infinity, // Set a maximum height
                  //   // minHeight: 28, // Set a minimum height
                  // ),
                ),
              ),
            ),
          );
        });
  }
}
