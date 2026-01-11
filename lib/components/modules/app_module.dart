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

  double get size_1W {
    final AppSize appSize = AppSize(context);
    // log("AppSizeWidth: ${appSize.screenWidth - AppSpacing.pageMargin * 6}");
    if (DeviceHelper.isMobile(context)) {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 2) / 2;
      return calculatedSize;
    } else {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 6) / 3.11;
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
                  left:
                      appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
                  right:
                      appSize.screenWidth < 1140 ? AppSpacing.containerInsideMargin : AppSpacing.containerInsideMargin,
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
                                        if (widget.module.button2Text(context) != null) ...[
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
                            ],
                          ],
                        );
                      },
                    ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: hide
                    ? Container()
                    : Container(
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
                          ),
                        ),
                        padding: EdgeInsets.only(
                          right: AppSpacing.groupMargin,
                          left: AppSpacing.groupMargin,
                          top: isMobile ? AppSpacing.tinyTinyMargin : AppSpacing.tinyMargin,
                          bottom: isMobile ? AppSpacing.tinyTinyMargin : AppSpacing.tinyMargin,
                        ),
                        child: _customisationRow(),
                      ),
              )
            ],
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BentoOption(
              iconPath: AppIcons.bento1_1Path,
              isSelected: widget.module.boxType == AppModuleType.type1,
              onTap: () {
                hide = true;
                setState(() {});
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
              onTap: () {
                hide = true;
                setState(() {});
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
              onTap: () {
                hide = true;
                setState(() {});
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
              onTap: () {
                hide = true;
                setState(() {});
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
