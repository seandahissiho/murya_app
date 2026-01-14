import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/module.dart';

class AppModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onCardTap;
  final bool hasData;
  final String? titleContent;
  final Widget? subtitleContent;
  final Widget? bodyContent;
  final Widget? footerContent;
  final Widget? content;
  final String? backgroundImage;
  final Widget? dragHandle;
  final GlobalKey? tileKey;
  final EdgeInsetsGeometry cardMargin;

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
    this.hasData = false,
    this.titleContent,
    this.subtitleContent,
    this.bodyContent,
    this.footerContent,
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
    this.dragHandle,
    this.tileKey,
    this.cardMargin = const EdgeInsets.all(4),
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

  @override
  void didUpdateWidget(covariant AppModuleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.module.boxType != widget.module.boxType) {
      hide = true;
      setState(() {});
    }
  }

  double get size_1W {
    final AppSize appSize = AppSize(context);
    final deviceType = DeviceHelper.getDeviceType(context);
    // log("AppSizeWidth: ${appSize.screenWidth - AppSpacing.pageMargin * 6}");
    if (deviceType == DeviceType.mobile) {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 2) / 2;
      return calculatedSize;
    } else {
      int sideMargins = 4;
      if (deviceType != DeviceType.desktop && deviceType != DeviceType.tablet) {
        sideMargins = 6;
      }
      // log("AppSizeWidthTabletAndAbove: ${appSize.screenWidth}");
      final double calculatedSize =
          (appSize.screenWidth - sideMargins * AppSpacing.pageMargin) / 3 - AppSpacing.containerInsideMarginSmall / 1.5;
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
      return math.max((availableHeight + AppSpacing.sectionMargin) / 4, size_1W);
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
        return size_1W - AppSpacing.elementMargin;

      // One row, Two Cols
      case AppModuleType.type1_2:
      // Two rows, Two Cols
      case AppModuleType.type2_2:
        return size_1W * 2 - AppSpacing.elementMargin;
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
    // final VoidCallback? primaryAction = widget.module.button1OnPressed(context);
    // final VoidCallback? secondaryAction = widget.module.button2OnPressed(context);
    // final VoidCallback? cardTapAction = widget.onCardTap ?? primaryAction;

    return Container(
      key: widget.tileKey,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        // margin: widget.cardMargin,
        elevation: .5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          onEnd: () {
            if (!mounted || !hide) return;
            setState(() => hide = false);
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Padding(
                  padding: getBoxPaddingForModuleType(context, widget.module.boxType, appSize, isMobile),
                  child: widget.hasData == false ? _defaultContent() : _buildContent(),
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
                      border: Border(
                        right: BorderSide(
                          color: AppColors.borderMedium,
                          width: 1.125,
                        ),
                        bottom: BorderSide(
                          color: AppColors.borderMedium,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      right: AppSpacing.groupMargin,
                      left: AppSpacing.groupMargin,
                      top: isMobile ? AppSpacing.tinyMargin : AppSpacing.tinyMargin + AppSpacing.tinyTinyMargin,
                      bottom: isMobile ? AppSpacing.tinyMargin : AppSpacing.tinyMargin + AppSpacing.tinyTinyMargin,
                    ),
                    child: _customisationRow(),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _customisationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BentoOption(
                  iconPath: AppIcons.bento1_1Path,
                  isSelected: widget.module.boxType == AppModuleType.type1,
                  onTap: () async {
                    hide = true;
                    setState(() {});
                    // await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted || !context.mounted) return;
                    widget.onSizeChanged!();
                    context.read<ModulesBloc>().add(UpdateModule(
                          module: Module(
                            id: widget.module.id,
                            index: widget.module.index,
                            boxType: AppModuleType.type1,
                          ),
                        ));
                  },
                ),
                AppSpacing.tinyTinyMarginBox,
                _BentoOption(
                  iconPath: AppIcons.bento2_1Path,
                  isSelected: widget.module.boxType == AppModuleType.type2_1,
                  onTap: () async {
                    hide = true;
                    setState(() {});
                    // await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted || !context.mounted) return;
                    widget.onSizeChanged!();
                    context.read<ModulesBloc>().add(UpdateModule(
                          module: Module(
                            id: widget.module.id,
                            index: widget.module.index,
                            boxType: AppModuleType.type2_1,
                          ),
                        ));
                  },
                ),
                AppSpacing.tinyTinyMarginBox,
                _BentoOption(
                  iconPath: AppIcons.bento1_2Path,
                  isSelected: widget.module.boxType == AppModuleType.type1_2,
                  onTap: () async {
                    hide = true;
                    setState(() {});
                    // await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted || !context.mounted) return;
                    widget.onSizeChanged!();
                    context.read<ModulesBloc>().add(UpdateModule(
                          module: Module(
                            id: widget.module.id,
                            index: widget.module.index,
                            boxType: AppModuleType.type1_2,
                          ),
                        ));
                  },
                ),
                AppSpacing.tinyTinyMarginBox,
                _BentoOption(
                  iconPath: AppIcons.bento2_2Path,
                  isSelected: widget.module.boxType == AppModuleType.type2_2,
                  onTap: () async {
                    hide = true;
                    setState(() {});
                    // await Future.delayed(const Duration(milliseconds: 100));
                    if (!mounted || !context.mounted) return;
                    widget.onSizeChanged!();
                    context.read<ModulesBloc>().add(UpdateModule(
                          module: Module(
                            id: widget.module.id,
                            index: widget.module.index,
                            boxType: AppModuleType.type2_2,
                          ),
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
        AppSpacing.containerInsideMarginSmallBox,
        Container(
          height: 24,
          width: 1,
          color: AppColors.borderMedium,
        ),
        AppSpacing.containerInsideMarginSmallBox,
        widget.dragHandle ?? const AppModuleDragHandle(),
      ],
    );
  }

  getBoxPaddingForModuleType(BuildContext context, AppModuleType boxType, AppSize appSize, bool isMobile) {
    if (isMobile) {
      if (boxType == AppModuleType.type1) {
        return const EdgeInsets.only(
          top: mobileCTAHeight + AppSpacing.elementMargin,
          left: AppSpacing.containerInsideMarginSmall,
          right: AppSpacing.containerInsideMarginSmall,
          bottom: AppSpacing.containerInsideMargin * 2 / 3,
        );
      }
      if (boxType == AppModuleType.type1_2) {
        return const EdgeInsets.only(
          top: mobileCTAHeight + AppSpacing.elementMargin,
          left: AppSpacing.containerInsideMarginSmall,
          right: AppSpacing.containerInsideMarginSmall,
          bottom: AppSpacing.containerInsideMargin * 2 / 3,
        );
      }
      if (boxType == AppModuleType.type2_1) {
        return const EdgeInsets.only(
          top: mobileCTAHeight + AppSpacing.elementMargin,
          left: AppSpacing.containerInsideMarginSmall,
          right: AppSpacing.containerInsideMarginSmall,
          bottom: AppSpacing.containerInsideMargin * 2 / 3,
        );
      }
      return const EdgeInsets.only(
        top: mobileCTAHeight + AppSpacing.elementMargin,
        left: AppSpacing.containerInsideMarginSmall,
        right: AppSpacing.containerInsideMarginSmall,
        bottom: AppSpacing.containerInsideMargin * 2 / 3,
      );
    }
    if (boxType == AppModuleType.type1) {
      return const EdgeInsets.only(
        top: AppSpacing.groupMargin + tabletAndAboveCTAHeight,
        left: AppSpacing.containerInsideMargin,
        right: AppSpacing.containerInsideMargin,
        bottom: AppSpacing.containerInsideMargin,
      );
    }
    if (boxType == AppModuleType.type1_2) {
      return const EdgeInsets.only(
        top: AppSpacing.groupMargin + tabletAndAboveCTAHeight,
        left: AppSpacing.containerInsideMargin,
        right: AppSpacing.containerInsideMargin,
        bottom: AppSpacing.containerInsideMargin,
      );
    }
    if (boxType == AppModuleType.type2_1) {
      return const EdgeInsets.only(
        top: AppSpacing.groupMargin + tabletAndAboveCTAHeight,
        left: AppSpacing.containerInsideMargin,
        right: AppSpacing.containerInsideMargin,
        bottom: AppSpacing.containerInsideMargin,
      );
    }
    return const EdgeInsets.only(
      top: AppSpacing.groupMargin + tabletAndAboveCTAHeight,
      left: AppSpacing.containerInsideMargin,
      right: AppSpacing.containerInsideMargin,
      bottom: AppSpacing.containerInsideMargin,
    );
  }

  List<Widget> getBoxContentDefaultWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    bool isMobile,
    VoidCallback? cardTapAction,
    BoxConstraints constraints,
  ) {
    if (isMobile) {
      return mobileBoxDefaultContentWidgets(
        context,
        module,
        titleMaxLines,
        titleMinFontSize,
        subtitleGap,
        primaryAction,
        secondaryAction,
        cardTapAction,
        constraints,
      );
    }
    return tabletAndAboveBoxDefaultContentWidgets(
      context,
      module,
      titleMaxLines,
      titleMinFontSize,
      subtitleGap,
      primaryAction,
      secondaryAction,
      cardTapAction,
      constraints,
    );
  }

  List<Widget> getBoxContentWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    bool isMobile,
    VoidCallback? cardTapAction,
    BoxConstraints constraints,
  ) {
    if (isMobile) {
      return mobileBoxContentWidgets(
        context,
        module,
        titleMaxLines,
        titleMinFontSize,
        subtitleGap,
        primaryAction,
        secondaryAction,
        cardTapAction,
        constraints,
      );
    }
    return tabletAndAboveBoxContentWidgets(
      context,
      module,
      titleMaxLines,
      titleMinFontSize,
      subtitleGap,
      primaryAction,
      secondaryAction,
      cardTapAction,
      constraints,
    );
  }

  List<Widget> mobileBoxDefaultContentWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      Expanded(
        child: InkWell(
          onTap: cardTapAction,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitleOnMobile(module)) ...[
                Flexible(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: AutoSizeText(
                      widget.module.title(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.anton(
                        color: AppColors.textPrimary,
                        fontSize: theme.textTheme.headlineSmall!.fontSize!,
                        fontWeight: FontWeight.w700,
                      ),
                      minFontSize: titleMinFontSize,
                    ),
                  ),
                ),
              ],
              if (showSubtitleOnMobile(module)) ...[
                SizedBox(height: subtitleGap),
                SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    widget.module.subtitle(context),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: theme.textTheme.bodyMedium!.fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (showButtonsOnMobile(widget.module))
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.groupMarginBox,
            ConstrainedBox(
              constraints: const BoxConstraints(
                  // maxWidth: size_1W,
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
                        shrinkWrap: false,
                        onPressed: primaryAction,
                        isLoading: false,
                        text: widget.module.button1Text(context) ?? '',
                        // borderColor: AppColors.whiteSwatch,
                        // bgColor: AppColors.whiteSwatch,
                        // fgColor: AppColors.primaryDefault,
                      ),
                    ),
                  ],
                  if (widget.module.button2Text(context) != null && showSecondButtonOnMobile(module)) ...[
                    AppSpacing.groupMarginBox,
                    Flexible(
                      child: AppXButton(
                        shrinkWrap: false,
                        onPressed: secondaryAction,
                        isLoading: false,
                        text: widget.module.button2Text(context) ?? '',
                        // bgColor: Colors.transparent,
                        // borderColor: AppColors.whiteSwatch,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    ];
  }

  List<Widget> mobileBoxContentWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      Expanded(
        child: InkWell(
          onTap: cardTapAction,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitleOnMobile(module)) ...[
                Flexible(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: AutoSizeText(
                      widget.module.title(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.anton(
                        color: AppColors.textPrimary,
                        fontSize: theme.textTheme.headlineSmall!.fontSize!,
                        fontWeight: FontWeight.w700,
                      ),
                      minFontSize: titleMinFontSize,
                    ),
                  ),
                ),
              ],
              if (showSubtitleOnMobile(module)) ...[
                SizedBox(height: subtitleGap),
                SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    widget.module.subtitle(context),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: theme.textTheme.bodyMedium!.fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (showButtonsOnMobile(widget.module))
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.groupMarginBox,
            ConstrainedBox(
              constraints: const BoxConstraints(
                  // maxWidth: size_1W,
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
                        shrinkWrap: false,
                        onPressed: primaryAction,
                        isLoading: false,
                        text: widget.module.button1Text(context) ?? '',
                        // borderColor: AppColors.whiteSwatch,
                        // bgColor: AppColors.whiteSwatch,
                        // fgColor: AppColors.primaryDefault,
                      ),
                    ),
                  ],
                  if (widget.module.button2Text(context) != null && showSecondButtonOnMobile(module)) ...[
                    AppSpacing.groupMarginBox,
                    Flexible(
                      child: AppXButton(
                        shrinkWrap: false,
                        onPressed: secondaryAction,
                        isLoading: false,
                        text: widget.module.button2Text(context) ?? '',
                        // bgColor: Colors.transparent,
                        // borderColor: AppColors.whiteSwatch,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    ];
  }

  List<Widget> tabletAndAboveBoxDefaultContentWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      Expanded(
        child: InkWell(
          onTap: cardTapAction,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitleOnTabletAndAbove(module))
                Flexible(
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: AutoSizeText(
                      widget.module.title(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.anton(
                        color: AppColors.textPrimary,
                        fontSize: theme.textTheme.displaySmall!.fontSize!,
                        fontWeight: FontWeight.w700,
                      ),
                      minFontSize: titleMinFontSize,
                    ),
                  ),
                ),
              if (showSubtitleOnTabletAndAbove(module)) ...[
                SizedBox(height: subtitleGap),
                SizedBox(
                  width: constraints.maxWidth,
                  child: Text(
                    widget.module.subtitle(context),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: theme.textTheme.bodyLarge!.fontSize,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      if (showButtonsOnTabletAndAbove(widget.module))
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.groupMarginBox,
            ConstrainedBox(
              constraints: const BoxConstraints(
                  // maxWidth: size_1W,
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
                        shrinkWrap: false,
                        onPressed: primaryAction,
                        isLoading: false,
                        text: widget.module.button1Text(context) ?? '',
                        // borderColor: AppColors.whiteSwatch,
                        // bgColor: AppColors.whiteSwatch,
                        // fgColor: AppColors.primaryDefault,
                      ),
                    ),
                  ],
                  if (widget.module.button2Text(context) != null && showSecondButtonOnTabletAndAbove(module)) ...[
                    AppSpacing.groupMarginBox,
                    Flexible(
                      child: AppXButton(
                        shrinkWrap: false,
                        onPressed: secondaryAction,
                        isLoading: false,
                        text: widget.module.button2Text(context) ?? '',
                        // bgColor: Colors.transparent,
                        // borderColor: AppColors.whiteSwatch,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    ];
  }

  List<Widget> tabletAndAboveBoxContentWidgets(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    if (module.boxType == AppModuleType.type2_2) {
      return tabletAndAboveBoxContentWidgetsFor2_2(
        context,
        module,
        titleMaxLines,
        titleMinFontSize,
        subtitleGap,
        primaryAction,
        secondaryAction,
        cardTapAction,
        constraints,
      );
    } else if (module.boxType == AppModuleType.type2_1) {
      return tabletAndAboveBoxContentWidgetsFor2_1(
        context,
        module,
        titleMaxLines,
        titleMinFontSize,
        subtitleGap,
        primaryAction,
        secondaryAction,
        cardTapAction,
        constraints,
      );
    } else if (module.boxType == AppModuleType.type1_2) {
      return tabletAndAboveBoxContentWidgetsFor1_2(
        context,
        module,
        titleMaxLines,
        titleMinFontSize,
        subtitleGap,
        primaryAction,
        secondaryAction,
        cardTapAction,
        constraints,
      );
    }
    return [
      if (showTitleOnTabletAndAbove(module)) ...[
        SizedBox(
          width: constraints.maxWidth,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  widget.module.title(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.anton(
                    color: AppColors.textPrimary,
                    fontSize: theme.textTheme.displaySmall!.fontSize!,
                    fontWeight: FontWeight.w700,
                  ),
                  minFontSize: titleMinFontSize,
                ),
              ),
              widget.subtitleContent!,
            ],
          ),
        ),
      ],
      Expanded(
        child: (showSubtitleOnTabletAndAbove(module))
            ? SizedBox(
                width: constraints.maxWidth,
                child: widget.bodyContent,
              )
            : const SizedBox.shrink(),
      ),
    ];
  }

  List<Widget> tabletAndAboveBoxContentWidgetsFor2_2(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      if (showTitleOnTabletAndAbove(module)) ...[
        SizedBox(
          width: constraints.maxWidth,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                  widget.module.title(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.anton(
                    color: AppColors.textPrimary,
                    fontSize: theme.textTheme.displaySmall!.fontSize!,
                    fontWeight: FontWeight.w700,
                  ),
                  minFontSize: titleMinFontSize,
                ),
              ),
              widget.subtitleContent!,
            ],
          ),
        ),
        AppSpacing.groupMarginBox,
      ],
      Expanded(
        child: (showSubtitleOnTabletAndAbove(module))
            ? SizedBox(
                width: constraints.maxWidth,
                child: widget.bodyContent,
              )
            : const SizedBox.shrink(),
      ),
      if (showButtonsOnTabletAndAbove(widget.module))
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.groupMarginBox,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (widget.module.button1Text(context) != null) ...[
                  Flexible(child: widget.footerContent!),
                ],
              ],
            ),
          ],
        ),
    ];
  }

  List<Widget> tabletAndAboveBoxContentWidgetsFor2_1(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      if (showTitleOnTabletAndAbove(module)) ...[
        SizedBox(
          width: constraints.maxWidth,
          child: AutoSizeText(
            widget.module.title(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.anton(
              color: AppColors.textPrimary,
              fontSize: theme.textTheme.displaySmall!.fontSize!,
              fontWeight: FontWeight.w700,
            ),
            minFontSize: titleMinFontSize,
          ),
        ),
        SizedBox(height: subtitleGap),
        widget.subtitleContent!,
        AppSpacing.groupMarginBox,
      ],
      Expanded(
        child: (showSubtitleOnTabletAndAbove(module))
            ? SizedBox(
                width: constraints.maxWidth,
                height: 200,
                child: widget.bodyContent,
              )
            : const SizedBox.shrink(),
      ),
      if (showButtonsOnTabletAndAbove(widget.module))
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.groupMarginBox,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (widget.module.button1Text(context) != null) ...[
                  Flexible(child: widget.footerContent!),
                ],
              ],
            ),
          ],
        ),
    ];
  }

  List<Widget> tabletAndAboveBoxContentWidgetsFor1_2(
    BuildContext context,
    Module module,
    int titleMaxLines,
    double titleMinFontSize,
    double subtitleGap,
    VoidCallback? primaryAction,
    VoidCallback? secondaryAction,
    cardTapAction,
    BoxConstraints constraints,
  ) {
    final ThemeData theme = Theme.of(context);
    return [
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showTitleOnTabletAndAbove(module)) ...[
                    SizedBox(
                      width: constraints.maxWidth,
                      child: AutoSizeText(
                        widget.module.title(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.anton(
                          color: AppColors.textPrimary,
                          fontSize: theme.textTheme.displaySmall!.fontSize!,
                          fontWeight: FontWeight.w700,
                        ),
                        minFontSize: titleMinFontSize,
                      ),
                    ),
                    SizedBox(height: subtitleGap),
                    widget.subtitleContent!,
                    AppSpacing.groupMarginBox,
                  ],
                  const Spacer(),
                  if (showButtonsOnTabletAndAbove(widget.module))
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.groupMarginBox,
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (widget.module.button1Text(context) != null) ...[
                              Flexible(child: widget.footerContent!),
                            ],
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            AppSpacing.containerInsideMarginBox,
            Expanded(
              flex: 50,
              child: (showSubtitleOnTabletAndAbove(module))
                  ? SizedBox(
                      width: constraints.maxWidth,
                      height: double.infinity,
                      child: widget.bodyContent,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ];
  }

  showTitleOnMobile(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return true;
  }

  showTitleOnTabletAndAbove(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return true;
  }

  showSubtitleOnMobile(Module module) {
    if (hide) return false;
    if (module.boxType == AppModuleType.type2_2) return !hide;
    if (module.boxType == AppModuleType.type2_1) return !hide;
    if (module.boxType == AppModuleType.type1_2) return false;
    if (module.boxType == AppModuleType.type1) return false;
  }

  showSubtitleOnTabletAndAbove(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return widget.hasData;
  }

  showButtonsOnMobile(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return true;
  }

  showButtonsOnTabletAndAbove(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return true;
  }

  showSecondButtonOnMobile(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return false;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return false;
  }

  showSecondButtonOnTabletAndAbove(Module module) {
    if (module.boxType == AppModuleType.type2_2) return true;
    if (module.boxType == AppModuleType.type2_1) return true;
    if (module.boxType == AppModuleType.type1_2) return true;
    if (module.boxType == AppModuleType.type1) return false;
  }

  _buildContent() {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    final VoidCallback? primaryAction = widget.module.button1OnPressed(context);
    final VoidCallback? secondaryAction = widget.module.button2OnPressed(context);
    final VoidCallback? cardTapAction = widget.onCardTap ?? primaryAction;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompactHeight = constraints.maxHeight < (isMobile ? 110 : 160);
        final int titleMaxLines = isCompactHeight ? 1 : 2;
        final double titleMinFontSize =
            isCompactHeight ? (theme.textTheme.bodySmall?.fontSize ?? 12) : theme.textTheme.bodyLarge!.fontSize!;
        final double subtitleGap = isCompactHeight ? AppSpacing.tinyTinyMargin : AppSpacing.tinyMargin;
        return InkWell(
          onTap: cardTapAction,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getBoxContentWidgets(
              context,
              widget.module,
              titleMaxLines,
              titleMinFontSize,
              subtitleGap,
              primaryAction,
              secondaryAction,
              isMobile,
              cardTapAction,
              constraints,
            ),
          ),
        );
      },
    );
  }

  _defaultContent() {
    final ThemeData theme = Theme.of(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    final VoidCallback? primaryAction = widget.module.button1OnPressed(context);
    final VoidCallback? secondaryAction = widget.module.button2OnPressed(context);
    final VoidCallback? cardTapAction = widget.onCardTap ?? primaryAction;
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isCompactHeight = constraints.maxHeight < (isMobile ? 110 : 160);
        final int titleMaxLines = isCompactHeight ? 1 : 2;
        final double titleMinFontSize =
            isCompactHeight ? (theme.textTheme.bodySmall?.fontSize ?? 12) : theme.textTheme.bodyLarge!.fontSize!;
        final double subtitleGap = isCompactHeight ? AppSpacing.tinyMargin : AppSpacing.elementMargin;
        return Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: getBoxContentDefaultWidgets(
            context,
            widget.module,
            titleMaxLines,
            titleMinFontSize,
            subtitleGap,
            primaryAction,
            secondaryAction,
            isMobile,
            cardTapAction,
            constraints,
          ),
        );
      },
    );
  }
}

enum _UiState { inactive, hover, active }

class AppModuleDragHandle extends StatefulWidget {
  const AppModuleDragHandle({super.key});

  @override
  State<AppModuleDragHandle> createState() => _AppModuleDragHandleState();
}

class _AppModuleDragHandleState extends State<AppModuleDragHandle> {
  bool isHovered = false;
  bool isPressed = false;

  _UiState get _state {
    if (isPressed) return _UiState.active;
    if (isHovered) return _UiState.hover;
    return _UiState.inactive;
  }

  @override
  Widget build(BuildContext context) {
    final s = _state;

    final Color iconColor = (s == _UiState.inactive) ? AppColors.textTertiary : AppColors.primaryDefault;

    final Color bgColor = (s == _UiState.active)
        ? AppColors.whiteSwatch
        : (s == _UiState.hover)
            ? AppColors.whiteSwatch.withOpacity(0.55)
            : Colors.transparent;

    final Color borderColor = (s == _UiState.active)
        ? AppColors.borderMedium
        : (s == _UiState.hover)
            ? AppColors.borderMedium.withOpacity(0.35)
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() {
        isHovered = false;
        isPressed = false; // sécurité si on sort pendant un press
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => isPressed = true),
        onTapUp: (_) => setState(() => isPressed = false),
        onTapCancel: () => setState(() => isPressed = false),

        // utile si tu commences un drag : onPanDown/onPanEnd gèrent le "pressed"
        onPanDown: (_) => setState(() => isPressed = true),
        onPanEnd: (_) => setState(() => isPressed = false),
        onPanCancel: () => setState(() => isPressed = false),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.tiny,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: SvgPicture.asset(
            AppIcons.bentoDragPath,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _BentoOption extends StatefulWidget {
  final String iconPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _BentoOption({
    required this.iconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BentoOption> createState() => _BentoOptionState();
}

class _BentoOptionState extends State<_BentoOption> {
  bool isHovered = false;

  _UiState get _state {
    if (widget.isSelected) return _UiState.active;
    if (isHovered) return _UiState.hover;
    return _UiState.inactive;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final s = _state;

      final Color iconColor = (s == _UiState.inactive) ? AppColors.textTertiary : AppColors.primaryDefault;

      final Color bgColor = (s == _UiState.active)
          ? AppColors.whiteSwatch
          : (s == _UiState.hover)
              ? AppColors.whiteSwatch.withOpacity(0.55)
              : Colors.transparent;

      final Color borderColor = (s == _UiState.active)
          ? AppColors.borderMedium
          : (s == _UiState.hover)
              ? AppColors.borderMedium.withOpacity(0.35)
              : Colors.transparent;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            height: constraints.maxHeight,
            width: constraints.maxHeight,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.tiny,
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.iconPath,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      );
    });
  }
}
