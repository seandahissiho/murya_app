import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/components/textfield_no_border.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';

class AppDatePicker extends StatefulWidget {
  final String? label;
  final String? hintText;
  final DateTime? date;
  final Function(DateTime)? onDateChanged;
  final bool checkEmpty;
  final bool noBorder;

  const AppDatePicker({
    super.key,
    this.label,
    this.hintText,
    this.date,
    this.onDateChanged,
    this.checkEmpty = false,
    this.noBorder = false,
  });

  @override
  State<AppDatePicker> createState() => _AppDatePickerState();
}

class _AppDatePickerState extends State<AppDatePicker> {
  final GlobalKey _dateWidgetKey = GlobalKey();
  DateTime? _date;

  @override
  void initState() {
    // Initialize _date with the provided date
    _date = widget.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.noBorder) {
      return GestureDetector(
        onTap: () async {
// 1. Grab RenderBox, position & size
          final renderBox = _dateWidgetKey.currentContext!.findRenderObject() as RenderBox;
          final widgetSize = renderBox.size;
          final widgetTopLeft = renderBox.localToGlobal(Offset.zero);

// 2. Screen dimensions
          final screenSize = MediaQuery.of(context).size;

// 3. Estimate dialog size (you can measure it offstage if dynamic)
          const dialogWidth = 400.0;
          const dialogHeight = 400.0;
          const margin = AppSpacing.tinyMargin;

// 4. Compute available space on each side
          final spaceAbove = widgetTopLeft.dy;
          final spaceBelow = screenSize.height - (widgetTopLeft.dy + widgetSize.height);
          final spaceLeft = widgetTopLeft.dx;
          final spaceRight = screenSize.width - (widgetTopLeft.dx + widgetSize.width);

// 5. Decide Y offset (vertical flip)
          final double yOffset = (spaceBelow < dialogHeight && spaceAbove > dialogHeight)
              // flip above
              ? widgetTopLeft.dy - dialogHeight - margin
              // normal below
              : widgetTopLeft.dy + widgetSize.height + margin - 20;

// 6. Decide X offset (horizontal flip)
          final double xOffset = (spaceRight < dialogWidth && spaceLeft > dialogWidth)
              // flip to left of widget
              ? widgetTopLeft.dx + widgetSize.width - dialogWidth
              // normal to right of widget
              : widgetTopLeft.dx;

// 7. Build globalPosition and show dialog
          final Offset globalPosition = Offset(xOffset, yOffset);

          final DateTime? result = await showDateCustomDialog(
            context,
            globalPosition,
            widget.date,
            null,
            null,
          );

          if (result != null) {
            DateTime time = DateTime(
              result.year,
              result.month,
              result.day,
            );
            _date = time;
            widget.onDateChanged?.call(time);
            setState(() {});
          }

          // final DateTime? date = await datePicker(context);
          // if (date != null) {
          //   setState(() {
          //     _date = date;
          //     // _endDateController.text = date.ddMMMyyyy();
          //   });
          // }
        },
        child: NoBorderTextField(
          enabled: false,
          key: UniqueKey(),
          keyboardType: TextInputType.text,
          definedKey: _dateWidgetKey,
          controller: TextEditingController(text: _date?.formattedDate()),
          hint: widget.hintText ?? 'Sélectionnez une date',
          validator: (String? value) {
            if (widget.checkEmpty == true && (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner une date';
            }
            if (value != null && value.isNotEmpty && _date == null) {
              return 'Veuillez sélectionner une date valide';
            }
            return null;
          },
        ),
      );
    }
    return AppTextFormField(
      key: UniqueKey(),
      definedKey: _dateWidgetKey,
      controller: TextEditingController(text: _date?.formattedDate()),
      label: widget.label,
      hintText: widget.hintText ?? 'Sélectionnez une date',
      // enabled: false,
      onTap: () async {
// 1. Grab RenderBox, position & size
        final renderBox = _dateWidgetKey.currentContext!.findRenderObject() as RenderBox;
        final widgetSize = renderBox.size;
        final widgetTopLeft = renderBox.localToGlobal(Offset.zero);

// 2. Screen dimensions
        final screenSize = MediaQuery.of(context).size;

// 3. Estimate dialog size (you can measure it offstage if dynamic)
        const dialogWidth = 400.0;
        const dialogHeight = 400.0;
        const margin = AppSpacing.tinyMargin;

// 4. Compute available space on each side
        final spaceAbove = widgetTopLeft.dy;
        final spaceBelow = screenSize.height - (widgetTopLeft.dy + widgetSize.height);
        final spaceLeft = widgetTopLeft.dx;
        final spaceRight = screenSize.width - (widgetTopLeft.dx + widgetSize.width);

// 5. Decide Y offset (vertical flip)
        final double yOffset = (spaceBelow < dialogHeight && spaceAbove > dialogHeight)
            // flip above
            ? widgetTopLeft.dy - dialogHeight - margin
            // normal below
            : widgetTopLeft.dy + widgetSize.height + margin - 20;

// 6. Decide X offset (horizontal flip)
        final double xOffset = (spaceRight < dialogWidth && spaceLeft > dialogWidth)
            // flip to left of widget
            ? widgetTopLeft.dx + widgetSize.width - dialogWidth
            // normal to right of widget
            : widgetTopLeft.dx;

// 7. Build globalPosition and show dialog
        final Offset globalPosition = Offset(xOffset, yOffset);

        final DateTime? result = await showDateCustomDialog(
          context,
          globalPosition,
          widget.date,
          null,
          null,
        );

        if (result != null) {
          DateTime time = DateTime(
            result.year,
            result.month,
            result.day,
          );
          _date = time;
          widget.onDateChanged?.call(time);
          setState(() {});
        }

        // final DateTime? date = await datePicker(context);
        // if (date != null) {
        //   setState(() {
        //     _date = date;
        //     // _endDateController.text = date.ddMMMyyyy();
        //   });
        // }
      },
      validator: (String? value) {
        if (widget.checkEmpty == true && (value == null || value.isEmpty)) {
          return 'Veuillez sélectionner une date';
        }
        if (value != null && value.isNotEmpty && _date == null) {
          return 'Veuillez sélectionner une date valide';
        }
        return null;
      },
    );
  }

  Future<DateTime?> showDateCustomDialog(
    BuildContext context,
    Offset position,
    DateTime? selectedDate,
    DateTime? shouldStartAfter,
    DateTime? shouldStartBefore,
  ) async {
    DateTime? date = selectedDate;
    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black38,
                      width: 1,
                    ),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: AppColors.backgroundColor,
                    //     blurRadius: 2,
                    //     spreadRadius: 1,
                    //   ),
                    // ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CalendarDatePicker2(
                      config: CalendarDatePicker2Config(
                        // firstDate: widget.minDate,
                        // lastDate: widget.maxDate,
                        currentDate: selectedDate ?? DateTime.now(),
                        selectedDayHighlightColor: AppColors.primary.shade400,
                      ),
                      value: [date],
                      onValueChanged: (dates) {
                        if (dates.isEmpty) return;
                        date = DateTime(
                          dates.first.year,
                          dates.first.month,
                          dates.first.day,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    return date;
  }
}
