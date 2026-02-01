import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:murya/config/DS.dart';

class NoBorderDropdown<T> extends StatefulWidget {
  final List<DropdownMenuItem2<T?>> items;
  final void Function(dynamic) onChanged;
  final String? hint;
  final T? selectedValue;

  const NoBorderDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.hint,
    this.selectedValue,
  });

  @override
  State<NoBorderDropdown> createState() => _NoBorderDropdownState();
}

class _NoBorderDropdownState<T> extends State<NoBorderDropdown> {
  T? selectedValue;

  @override
  void initState() {
    selectedValue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        log('Dropdown tapped: ${widget.hint ?? 'No hint provided'}, selected value: $selectedValue, items count: ${widget.items.length}');
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.only(bottom: AppSpacing.spacing4),
        child: Theme(
          data: ThemeData(),
          child: DropdownButton<T?>(
            value: selectedValue,
            hint: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(widget.hint ?? 'Sélectionner',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.whiteSwatch.shade500,
                    )),
              ],
            ),
            icon: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.arrow_drop_down, color: AppColors.whiteSwatch.shade900),
              ],
            ),
            style: theme.textTheme.bodyMedium,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing40),
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
              });
              widget.onChanged(newValue);
            },
            items: widget.items.map<DropdownMenuItem<T?>>((item) {
              return DropdownMenuItem(
                value: item.value,
                child: Tooltip(
                  message: item.tooltipMessage ?? "",
                  child: item.child,
                ),
              );
            }).toList(),
            isExpanded: true,
            underline: Container(), // No underline
          ),
        ),
      ),
    );
  }
}

const double _kMenuItemHeight = kMinInteractiveDimension;

class _DropdownMenuItemContainer extends StatelessWidget {
  /// Creates an item for a dropdown menu.
  ///
  /// The [child] argument is required.
  const _DropdownMenuItemContainer({
    super.key,
    this.alignment = AlignmentDirectional.centerStart,
    required this.child,
  });

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text] widget.
  final Widget child;

  /// Defines how the item is positioned within the container.
  ///
  /// Defaults to [AlignmentDirectional.centerStart].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: _kMenuItemHeight),
        child: Align(alignment: alignment, child: child),
      ),
    );
  }
}

class DropdownMenuItem2<T> extends _DropdownMenuItemContainer {
  /// Creates an item for a dropdown menu.
  ///
  /// The [child] argument is required.
  const DropdownMenuItem2({
    super.key,
    this.onTap,
    this.value,
    this.tooltipMessage,
    this.enabled = true,
    super.alignment,
    required super.child,
  });

  /// Called when the dropdown menu item is tapped.
  final VoidCallback? onTap;

  /// The value to return if the user selects this menu item.
  ///
  /// Eventually returned in a call to [DropdownButton.onChanged].
  final T? value;

  /// Whether or not a user can select this menu item.
  ///
  /// Defaults to `true`.
  final bool enabled;

  /// The message to show in a tooltip when the user hovers over this menu item.
  /// If null, no tooltip is shown.
  final String? tooltipMessage;
}
