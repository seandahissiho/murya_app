import 'dart:async';

import 'package:flutter/material.dart';
import 'package:murya/components/glass_container.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/config/app_icons.dart';

class SearchField extends StatefulWidget {
  final double? maxWidth;
  final double height;
  final Function(String query) onSearch;

  const SearchField({
    super.key,
    this.maxWidth,
    this.height = 40,
    required this.onSearch,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  /// Timer used for debouncing input.
  Timer? _debounce;

  /// Duration to wait after the last keystroke before firing search.
  static const Duration _debounceDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Cancel any existing timer.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // Start a new timer; when it fires, call the onSearch callback.
    _debounce = Timer(_debounceDuration, () {
      widget.onSearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Flexible(
      flex: 5,
      child: GlassContainer(
        height: widget.height - 5,
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth ?? theme.inputDecorationTheme.constraints?.maxWidth ?? double.infinity,
        ),
        lighter: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: AppTextField(
                leftIcon: AppIcons.searchIconPath,
                rightIcon: AppIcons.clearIconPath,
                controller: _searchController,
                focusNode: _searchFocusNode,
                dynamicWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
