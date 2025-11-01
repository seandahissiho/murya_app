import 'dart:async';

import 'package:flutter/foundation.dart';
// import 'package:country_pickers/country.dart' show AppCountry;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/components/textfield_no_border.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/search_service.dart';

class AppTypeAheadField<T> extends StatefulWidget {
  final String? label;
  final String? hintText;
  final SearchService<T> service;
  final Widget Function(dynamic)? createOrEditObjWidget;
  final bool showSubtitle;
  final T? selectedObj;
  final void Function(dynamic) onObjSelected;
  final bool enableCreate;
  final TextEditingController? controller;
  final bool tagsMode;
  final bool noBorder;
  final dynamic creationData;
  final bool enabled;

  const AppTypeAheadField({
    required super.key,
    this.label,
    this.hintText,
    required this.service,
    this.createOrEditObjWidget,
    this.showSubtitle = true,
    this.selectedObj,
    required this.onObjSelected,
    this.enableCreate = true,
    this.controller,
    this.tagsMode = false,
    this.noBorder = false,
    this.creationData,
    this.enabled = true,
  });

  @override
  State<AppTypeAheadField> createState() => _AppTypeAheadFieldState<T>();
}

class _AppTypeAheadFieldState<T> extends State<AppTypeAheadField> {
  late final TextEditingController _controller;
  final SuggestionsController<T> _suggestionsController = SuggestionsController<T>();
  final FocusNode _focusNode = FocusNode();
  T? _selectedObj;

  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
    if (widget.selectedObj != null) {
      _selectedObj = widget.selectedObj;
      _controller.text = widget.selectedObj?.name ?? '';
    }
    if (widget.tagsMode) {
      _controller.addListener(() {
        if (_controller.text.isEmpty) {
          _suggestionsController.close();
          setState(() {});
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TypeAheadField<T>(
      suggestionsController: _suggestionsController,
      controller: _controller,
      focusNode: _focusNode,
      suggestionsCallback: (search) => widget.service.find(search, context) as FutureOr<List<T>>,
      builder: (context, controller, focusNode) {
        if (widget.noBorder) {
          return NoBorderTextField(
            enabled: widget.enabled,
            controller: controller,
            focusNode: focusNode,
            hint: widget.hintText ?? '',
            keyboardType: TextInputType.text,
            onTapOutside: (event) {
              // Close the keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            onFocusChanged: (value) {
              if (value == true) {
                // auto launch search when focusing
                _suggestionsController.refresh();
              }
            },
          );
        }
        return AppTextFormField(
          enabled: widget.enabled,
          controller: controller,
          focusNode: focusNode,
          onTapOutside: (event) {
            // Close the keyboard when tapping outside
            FocusScope.of(context).unfocus();
          },
          // onTap: () {
          //   _suggestionsController.open();
          // },
          onFocusChanged: (value) {
            if (value == true) {
              // auto launch search when focusing
              _suggestionsController.refresh();
            }
          },
          label: widget.label,
          hintText: widget.hintText,
        );
      },
      itemBuilder: (context, obj) {
        return ListTile(
          tileColor: AppColors.backgroundColor,
          selectedColor: AppColors.backgroundColor,
          selectedTileColor: AppColors.backgroundColor,
          focusColor: AppColors.backgroundColor,
          hoverColor: AppColors.backgroundColor,
          splashColor: AppColors.backgroundColor,
          title: Text(obj?.tileTitle ?? '-'),
          subtitle: widget.showSubtitle ? Text(obj?.tileSubtitle ?? '-') : null,
        );
      },
      onSelected: (obj) {
        // Handle the selected client
        if (kDebugMode) {
          print('Selected obj: ${obj?.runtimeType}');
        }
        _selectedObj = obj;
        _controller.text = obj?.name ?? '';
        widget.onObjSelected.call(obj);
        setState(() {});
      },
      loadingBuilder: (context) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            tileColor: AppColors.backgroundColor,
            selectedColor: AppColors.backgroundColor,
            selectedTileColor: AppColors.backgroundColor,
            focusColor: AppColors.backgroundColor,
            hoverColor: AppColors.backgroundColor,
            splashColor: AppColors.backgroundColor,
          ),
        );
      },
      errorBuilder: (context, error) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            tileColor: AppColors.backgroundColor,
            selectedColor: AppColors.backgroundColor,
            selectedTileColor: AppColors.backgroundColor,
            focusColor: AppColors.backgroundColor,
            hoverColor: AppColors.backgroundColor,
            splashColor: AppColors.backgroundColor,
          ),
        );
      },
      emptyBuilder: (context) {
        if (_controller.text.isEmpty && (_suggestionsController.suggestions?.isEmpty ?? true)) {
          return Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.enableCreate) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    tileColor: AppColors.backgroundColor,
                    selectedColor: AppColors.backgroundColor,
                    selectedTileColor: AppColors.backgroundColor,
                    focusColor: AppColors.backgroundColor,
                    hoverColor: AppColors.backgroundColor,
                    splashColor: AppColors.backgroundColor,
                    title: Text(
                      'Créer "${_controller.text}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.whiteSwatch.shade600,
                      ),
                    ),
                    onTap: () async {
                      final T newObj = await widget.service.createFromName
                          .call(_controller.text, context, data: widget.creationData);
                      if (newObj != null) {
                        _selectedObj = newObj;
                        _controller.text = newObj.name;
                        setState(() {});
                        widget.onObjSelected.call(newObj);
                        Future.delayed(const Duration(milliseconds: 250), () {
                          if (!mounted || !context.mounted) return;
                          FocusScope.of(context).unfocus();
                          _focusNode.unfocus();
                        });
                      }
                    },
                  ),
                ),
              ],
              if (widget.createOrEditObjWidget != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    tileColor: AppColors.backgroundColor,
                    selectedColor: AppColors.backgroundColor,
                    selectedTileColor: AppColors.backgroundColor,
                    focusColor: AppColors.backgroundColor,
                    hoverColor: AppColors.backgroundColor,
                    splashColor: AppColors.backgroundColor,
                    title: Text(
                      'Créer et modifier "${_controller.text}"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.whiteSwatch.shade600,
                      ),
                    ),
                    onTap: () async {
                      if (widget.createOrEditObjWidget == null) {
                        return;
                      }
                      final result = await overlayMenu(
                        context: context,
                        leaveAllOpen: false,
                        medium: true,
                        child: widget.createOrEditObjWidget!.call(_controller.text),
                      );

                      if (result != null) {
                        _selectedObj = result;
                        _controller.text = result.name;
                        await Future.delayed(const Duration(milliseconds: 250));
                        _suggestionsController.close();
                        setState(() {});
                        widget.onObjSelected.call(result);
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
