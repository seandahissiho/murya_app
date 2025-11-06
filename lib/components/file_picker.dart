import 'package:flutter/material.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/file_manager/file_manager.dart';

class AppFilePicker extends StatefulWidget {
  final String? label;
  final String? hint;
  final dynamic selectedFile;
  final Function(dynamic file) onFileSelected;

  const AppFilePicker({
    super.key,
    this.selectedFile,
    required this.onFileSelected,
    this.label,
    this.hint,
  });

  @override
  State<AppFilePicker> createState() => _AppFilePickerState();
}

class _AppFilePickerState extends State<AppFilePicker> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextFormField(
          key: UniqueKey(),
          label: widget.label,
          hintText: widget.selectedFile != null ? (widget.selectedFile as Object).name : 'Aucun fichier sélectionné',
          // enabled: false,
          leadingIcon: Icons.attach_file,
          contentPadding: const EdgeInsets.only(
            left: AppSpacing.containerInsideMargin / 2,
            right: AppSpacing.containerInsideMargin / 2,
            top: AppSpacing.containerInsideMargin / 2,
          ),
          onTap: () async {
            dynamic file = await FileManager.pickFile();
            if (file != null) {
              widget.onFileSelected(file);
              setState(() {});
            }
          },
        ),
      ],
    );
  }
}
