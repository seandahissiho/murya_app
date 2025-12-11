import 'dart:developer';
import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/module.dart';

class AppModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onCardTap;
  final Widget? content;
  final String? backgroundImage;

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
    this.onCardTap,
    this.content,
    // this.title = '',
    // this.subtitle = '',
    // this.boxType = AppModuleType.type2_2,
    // this.imagePath = AppImages.homeBox1Path,
    // this.button1Text,
    // this.button2Text,
    // this.button1OnPressed,
    // this.button2OnPressed,
    this.onSizeChanged,
    this.backgroundImage,
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
    final VoidCallback? primaryAction = widget.module.button1OnPressed(context);
    final VoidCallback? secondaryAction = widget.module.button2OnPressed(context);
    final VoidCallback? cardTapAction = widget.onCardTap ?? primaryAction;

    return AnimatedContainer(
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
        image: widget.backgroundImage != null
            ? DecorationImage(
                image: AssetImage(widget.backgroundImage!),
                fit: BoxFit.cover,
              )
            : null,
        borderRadius: BorderRadius.circular(24),
      ),
      // padding: EdgeInsets.all(
      //   appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
      // ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(
              appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
            ),
            child: widget.content ??
                LayoutBuilder(builder: (context, constraints) {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: cardTapAction,
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
                                      fontSize: isMobile
                                          ? theme.textTheme.bodyMedium!.fontSize
                                          : theme.textTheme.bodyLarge!.fontSize,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (hide == false && constraints.maxHeight >= 163 + (isMobile ? 0 : 36)) ...[
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSpacing.groupMarginBox,
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: size_1W,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                // runSpacing: AppSpacing.elementMargin,
                                // spacing: AppSpacing.elementMargin,
                                children: [
                                  if (widget.module.button1Text(context) != null) ...[
                                    Flexible(
                                      child: AppXButton(
                                        autoResize: false,
                                        onPressed: primaryAction,
                                        isLoading: false,
                                        text: widget.module.button1Text(context) ?? '',
                                        borderColor: AppColors.whiteSwatch,
                                        bgColor: AppColors.whiteSwatch,
                                        fgColor: AppColors.primaryDefault,
                                      ),
                                    ),
                                  ],
                                  if (widget.module.button2Text(context) != null) ...[
                                    AppSpacing.groupMarginBox,
                                    Flexible(
                                      child: AppXButton(
                                        autoResize: false,
                                        onPressed: secondaryAction,
                                        isLoading: false,
                                        text: widget.module.button2Text(context) ?? '',
                                        bgColor: Colors.transparent,
                                        borderColor: AppColors.whiteSwatch,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                }),
          ),
          Positioned(
            top: AppSpacing.containerInsideMargin / 1.25,
            right: AppSpacing.containerInsideMarginSmall / 2,
            child: InkWell(
              onTap: () {
                log("Module ${widget.module.id} tapped");
                // widget.module.button1OnPressed(context);
                hide = true;
                setState(() {});
                widget.onSizeChanged!();
                context.read<ModulesBloc>().add(UpdateModule(
                      module: Module(
                        id: widget.module.id,
                        index: widget.module.index,
                        boxType: widget.module.nextBoxType(),
                      ),
                    ));
              },
              child: SizedBox(
                height: 50,
                child: Center(
                  child: Icon(
                    Icons.more_vert,
                    color: AppColors.whiteSwatch,
                    size: 24,
                    opticalSize: 48,
                    applyTextScaling: true,
                    fill: 1.0,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
