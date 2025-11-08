import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/module.dart';
import 'package:provider/provider.dart';

class AppModuleWidget extends StatefulWidget {
  final Module module;
  // final String title;
  // final String subtitle;
  // final AppModuleType boxType;
  // final String imagePath;
  // final String? button1Text;
  // final String? button2Text;
  // final VoidCallback? button1OnPressed;
  // final VoidCallback? button2OnPressed;
  final VoidCallback? onSizeChanged;

  const AppModuleWidget({
    super.key,
    required this.module,
    // this.title = '',
    // this.subtitle = '',
    // this.boxType = AppModuleType.type2_2,
    // this.imagePath = AppImages.homeBox1Path,
    // this.button1Text,
    // this.button2Text,
    // this.button1OnPressed,
    // this.button2OnPressed,
    this.onSizeChanged,
  });

  @override
  State<AppModuleWidget> createState() => _AppModuleWidgetState();
}

class _AppModuleWidgetState extends State<AppModuleWidget> {
  late final EdgeInsets safeAreaPadding;

  bool hide = false;

  @override
  initState() {
    super.initState();
    safeAreaPadding = context.read<AppBloc>().safeAreaPadding;
  }

  double get size_1W {
    final AppSize appSize = AppSize(context);
    // log("AppSizeWidth: ${appSize.screenWidth - AppSpacing.pageMargin * 6}");
    if (DeviceHelper.isMobile(context)) {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 2) / 2;
      return calculatedSize;
    } else {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 6) / 3;
      return calculatedSize;
    }
  }

  double get size_1H {
    final AppSize appSize = AppSize(context);
    final screenHeight = appSize.screenHeight;
    // remove all margins and paddings
    final availableHeight = screenHeight -
        safeAreaPadding.top -
        safeAreaPadding.bottom -
        (AppSpacing.pageMargin * 2) -
        27 -
        AppSpacing.sectionMargin;
    if (DeviceHelper.isMobile(context)) {
      return (availableHeight + AppSpacing.sectionMargin) / 4;
    } else {
      // return ((availableHeight - AppSpacing.groupMargin) / 2) / 1.618;
      return math.max((availableHeight) / 3, 325);
    }
  }

  double get width {
    switch (widget.module.boxType) {
      // One row, One Col
      case AppModuleType.type1:
      // Two rows, One Col
      case AppModuleType.type2_1:
        return size_1W - AppSpacing.groupMargin;

      // One row, Two Cols
      case AppModuleType.type1_2:
      // Two rows, Two Cols
      case AppModuleType.type2_2:
        return size_1W * 2 - AppSpacing.groupMargin;
    }
  }

  double get height {
    switch (widget.module.boxType) {
      // One row, One Col
      case AppModuleType.type1:
      // One row, Two Cols
      case AppModuleType.type1_2:
        return size_1H - AppSpacing.groupMargin;

      // Two rows, One Col
      case AppModuleType.type2_1:
      // Two rows, Two Cols
      case AppModuleType.type2_2:
        return size_1H * 2 - AppSpacing.groupMargin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final appSize = AppSize(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    return InkWell(
      onTap: widget.module.button1OnPressed(context) ?? () {},
      // onTap: () {
      //   log("Module ${widget.module.id} tapped");
      //   widget.module.button1OnPressed(context);
      //   // hide = true;
      //   // setState(() {});
      //   // widget.onSizeChanged!();
      //   // context.read<ModulesBloc>().add(UpdateModule(
      //   //       module: Module(
      //   //         id: widget.module.id,
      //   //         index: widget.module.index,
      //   //         boxType: widget.module.nextBoxType(),
      //   //       ),
      //   //     ));
      // },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        onEnd: () {
          hide = false;
          setState(() {});
        },
        decoration: BoxDecoration(
          color: AppColors.primaryDefault,
          // image: DecorationImage(
          //   image: AssetImage(widget.imagePath),
          //   fit: BoxFit.cover,
          // ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.all(
          appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hide == false) ...[
                      Flexible(
                        child: SizedBox(
                          width: constraints.maxWidth * 0.85,
                          child: AutoSizeText(
                            widget.module.title(context),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.anton(
                              color: Colors.white,
                              fontSize: isMobile
                                  ? theme.textTheme.headlineSmall!.fontSize!
                                  : theme.textTheme.displaySmall!.fontSize!,
                              fontWeight: FontWeight.w700,
                            ),
                            minFontSize: theme.textTheme.bodyLarge!.fontSize!,
                          ),
                        ),
                      ),
                    ],
                    if (hide == false && constraints.maxHeight >= 145) ...[
                      AppSpacing.elementMarginBox,
                      SizedBox(
                        width: constraints.maxWidth,
                        child: Text(
                          widget.module.subtitle(context),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize:
                                isMobile ? theme.textTheme.bodyMedium!.fontSize : theme.textTheme.bodyLarge!.fontSize,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hide == false && constraints.maxHeight >= 163 + (isMobile ? 0 : 36)) ...[
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    AppSpacing.groupMarginBox,
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      // runSpacing: AppSpacing.elementMargin,
                      // spacing: AppSpacing.elementMargin,
                      children: [
                        if (widget.module.button1Text(context) != null) ...[
                          Flexible(
                            child: AppXButton(
                              onPressed: widget.module.button1OnPressed(context) ?? () {},
                              isLoading: false,
                              text: widget.module.button1Text(context) ?? '',
                              borderColor: AppColors.whiteSwatch,
                              background: AppColors.whiteSwatch,
                              foregroundColor: AppColors.primaryDefault,
                            ),
                          ),
                          AppSpacing.elementMarginBox,
                        ],
                        if (widget.module.button2Text(context) != null) ...[
                          Flexible(
                            child: AppXButton(
                              onPressed: widget.module.button2OnPressed(context) ?? () {},
                              isLoading: false,
                              text: widget.module.button2Text(context) ?? '',
                              background: Colors.transparent,
                              borderColor: AppColors.whiteSwatch,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}
