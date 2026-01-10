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
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 6) / 3.06;
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
      return math.max((availableHeight) / 2 - 90, 225);
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

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 1.5,
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
          color: AppColors.backgroundColor,
          image: widget.backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(widget.backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.borderMedium,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: appSize.screenWidth < 1140
                    ? AppSpacing.containerInsideMargin
                    : AppSpacing.containerInsideMarginSmall,
                left: appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
                right: appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
                bottom:
                    appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
              ),
              child: widget.content ??
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            // width: constraints.maxWidth,
                            height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                          ),
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
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.anton(
                                            color: AppColors.textPrimary,
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
                                          color: AppColors.textPrimary,
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
                    },
                  ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: width,
                height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E3D7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
