import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/module.dart';
import 'package:provider/provider.dart';

class AppModuleWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final AppModuleType boxType;
  final String imagePath;
  final String? button1Text;
  final String? button2Text;
  final VoidCallback? button1OnPressed;
  final VoidCallback? button2OnPressed;

  const AppModuleWidget({
    super.key,
    this.title = '',
    this.subtitle = '',
    this.boxType = AppModuleType.type2_2,
    this.imagePath = AppImages.homeBox1Path,
    this.button1Text,
    this.button2Text,
    this.button1OnPressed,
    this.button2OnPressed,
  });

  @override
  State<AppModuleWidget> createState() => _AppModuleWidgetState();
}

class _AppModuleWidgetState extends State<AppModuleWidget> {
  late final EdgeInsets safeAreaPadding;

  @override
  initState() {
    super.initState();
    safeAreaPadding = context.read<AppBloc>().safeAreaPadding;
  }

  double get size_1W {
    final AppSize appSize = AppSize(context);
    if (DeviceHelper.isMobile(context)) {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 2) / 2;
      return calculatedSize;
    } else {
      final double calculatedSize = (appSize.screenWidth - AppSpacing.pageMargin * 2 - AppSpacing.groupMargin * 2) / 4;
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
    return ((availableHeight - AppSpacing.groupMargin) / 4) / 1.618;
    if (DeviceHelper.isMobile(context)) {
      return (availableHeight - AppSpacing.groupMargin) / 8;
    } else {
      return (availableHeight - AppSpacing.groupMargin) / 8;
    }
  }

  double get width {
    switch (widget.boxType) {
      case AppModuleType.type1:
      case AppModuleType.type2_1:
        // case AppModuleType.type3_1:
        return size_1W;
      case AppModuleType.type1_2:
      case AppModuleType.type2_2:
        // case AppModuleType.type3_2:
        return size_1W * 2;
        // case AppModuleType.type1_3:
        // case AppModuleType.type2_3:
        // case AppModuleType.type3_3:
        return size_1W * 3;
    }
  }

  double get height {
    switch (widget.boxType) {
      case AppModuleType.type1:
      case AppModuleType.type1_2:
        // case AppModuleType.type1_3:
        return size_1H;
      case AppModuleType.type2_1:
      case AppModuleType.type2_2:
        // case AppModuleType.type2_3:
        return size_1H * 2;
        // case AppModuleType.type3_1:
        // case AppModuleType.type3_2:
        // case AppModuleType.type3_3:
        return size_1H * 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final appSize = AppSize(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    return Container(
      width: width,
      height: height,
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
                  Flexible(
                    child: SizedBox(
                      width: constraints.maxWidth * 0.85,
                      child: AutoSizeText(
                        widget.title,
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
                  if (constraints.maxHeight >= 145) ...[
                    AppSpacing.elementMarginBox,
                    SizedBox(
                      width: constraints.maxWidth,
                      child: Text(
                        widget.subtitle,
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
            if (constraints.maxHeight >= 163 + (isMobile ? 0 : 36)) ...[
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                // runSpacing: AppSpacing.elementMargin,
                // spacing: AppSpacing.elementMargin,
                children: [
                  if (widget.button1Text != null) ...[
                    Flexible(
                      child: AppXButton(
                        onPressed: widget.button1OnPressed ?? () {},
                        isLoading: false,
                        text: widget.button1Text ?? '',
                        borderColor: AppColors.whiteSwatch,
                        background: AppColors.whiteSwatch,
                        foregroundColor: AppColors.primaryDefault,
                      ),
                    ),
                    AppSpacing.elementMarginBox,
                  ],
                  if (widget.button2Text != null) ...[
                    Flexible(
                      child: AppXButton(
                        onPressed: widget.button2OnPressed ?? () {},
                        isLoading: false,
                        text: widget.button2Text ?? '',
                        background: Colors.transparent,
                        borderColor: AppColors.whiteSwatch,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        );
      }),
    );
  }

  getTitleFontSizeBasedOnWidth(double maxWidth) {
    // normal size is 36, reduce it based on width
    if (maxWidth >= 400) {
      if (widget.boxType == AppModuleType.type1_2) {
        return 32.0;
      }
      return 36.0;
    } else if (maxWidth >= 300) {
      if (widget.boxType == AppModuleType.type1_2) {
        return 24.0;
      }
      return 28.0;
    } else {
      if (widget.boxType == AppModuleType.type1_2) {
        return 22.0;
      }
      return 12.25;
    }
  }
}
