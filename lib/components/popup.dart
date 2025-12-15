import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/glass_container.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';

const double kNavBarWidth = 255.0; // Width of the side navigation bar

Future<T?> displayPopUp<T>({
  required BuildContext context,
  List<Widget>? contents,
  String? title,
  String? description,
  bool noActions = false,
  String okText = "Confirmer",
  bool okEnabled = true,
  bool cancelEnabled = true,
  String? cancelText,
  String? iconPath,
  bool barrierDismissible = true,
  Alignment contentAlignment = Alignment.centerLeft,
  double? width,
}) async {
  return await showDialog<T?>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        final ThemeData theme = Theme.of(context);
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
            constraints: BoxConstraints(
              maxWidth: width ?? DeviceHelper.kMainBodyWidth(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.whiteSwatch,
              borderRadius: AppRadius.medium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: contentAlignment == Alignment.centerLeft
                  ? CrossAxisAlignment.start
                  : contentAlignment == Alignment.centerRight
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.center,
              children: contents != null
                  ? [
                      ...contents,
                      if (!noActions)
                        Row(
                          children: [
                            Flexible(
                              child: AppXButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                isLoading: false,
                                disabled: !okEnabled,
                                autoResize: false,
                                text: okText,
                              ),
                            ),
                            if (cancelText != null) ...[
                              AppSpacing.elementMarginBox,
                              Flexible(
                                child: AppXButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  isLoading: false,
                                  disabled: !cancelEnabled,
                                  autoResize: false,
                                  text: cancelText,
                                  bgColor: AppColors.whiteSwatch,
                                  borderColor: AppColors.primary.shade200,
                                  fgColor: AppColors.primary.shade700,
                                ),
                              ),
                            ],
                          ],
                        )
                    ]
                  : [
                      if (iconPath != null) ...[
                        SvgPicture.asset(
                          iconPath,
                          height: 40,
                          width: 40,
                          colorFilter: ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcATop,
                          ),
                        ),
                      ],
                      AppSpacing.sectionMarginBox,
                      Text(
                        title ?? '',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.groupMarginBox,
                      Text(
                        description ?? '',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.sectionMarginBox,
                      AppSpacing.sectionMarginBox,
                      LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (cancelText != null) ...[
                              AppXButton(
                                autoResize: false,
                                maxWidth: constraints.maxWidth / 2 - AppSpacing.elementMargin * 2,
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                isLoading: false,
                                text: cancelText,
                                bgColor: AppColors.whiteSwatch,
                                borderColor: AppColors.primary.shade200,
                                fgColor: AppColors.primary.shade700,
                              ),
                              AppSpacing.elementMarginBox,
                            ],
                            AppXButton(
                              autoResize: false,
                              maxWidth: constraints.maxWidth / 2 - AppSpacing.elementMargin * 2,
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              isLoading: false,
                              text: okText,
                            ),
                          ],
                        );
                      }),
                    ],
            ),
          ),
        );
      });
    },
  );
}

Future<T?> overlayMenu<T>({
  required BuildContext context,
  required Widget child,
  bool tiny = false,
  bool small = false,
  bool medium = false,
  bool leaveAllOpen = false,
  bool onRigthSide = false,
  bool onLeftSide = false,
  bool onBottomSide = false,
  bool onTopSide = false,
  bool dismissible = true,
  bool uniqueKey = false,
  bool canMove = false,
  double? width,
  // required AppSize appSize,
}) async {
  if (context.mounted) {
    BlocProvider.of<NotificationBloc>(context).updateContext(context);
  }
  final result = await showDialog(
    context: context,
    barrierDismissible: dismissible && !leaveAllOpen,
    // barrierColor: Colors.black54.withAlpha(50),
    barrierColor: dismissible ? Colors.transparent : Colors.black54.withAlpha(25),
    useSafeArea: false,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return OverlayMenuContent(
            key: uniqueKey ? UniqueKey() : null,
            width: width,
            tiny: tiny,
            small: small,
            medium: medium,
            leaveAllOpen: leaveAllOpen,
            onLeftSide: onLeftSide,
            onRightSide: onRigthSide,
            onTopSide: onTopSide,
            onBottomSide: onBottomSide,
            canMove: canMove,
            child: child,
          );
        },
      );
    },
  );
  if (context.mounted) {
    BlocProvider.of<NotificationBloc>(context).updateContext(context);
  }
  return result;
}

class OverlayMenuContent extends StatefulWidget {
  final Widget child;
  final bool tiny;
  final bool small;
  final bool medium;
  final bool leaveAllOpen;
  final bool onLeftSide;
  final bool onRightSide;
  final bool onBottomSide;
  final bool onTopSide;
  final double? width;
  final bool canMove;

  static const double tinyWidth = 380;
  static const double smallWidth = 460;
  static const double mediumWidth = smallWidth + smallWidth / 1.5;

  const OverlayMenuContent({
    super.key,
    this.width,
    required this.child,
    this.tiny = false,
    this.small = false,
    this.medium = false,
    this.leaveAllOpen = true,
    this.onLeftSide = false,
    this.onRightSide = false,
    this.onBottomSide = false,
    this.onTopSide = false,
    this.canMove = false,
  });

  @override
  State<OverlayMenuContent> createState() => _OverlayMenuContentState();
}

class _OverlayMenuContentState extends State<OverlayMenuContent> {
  // 1. Track drag offsets
  double _dragOffsetX = 0;
  double _dragOffsetY = 0;

  double? get top {
    if (widget.onBottomSide) return null;
    if (widget.onTopSide) return MediaQuery.of(context).padding.top;
    if (widget.tiny || widget.small || widget.medium) return 0.0;
    return null; // Default case, can be adjusted as needed
  }

  double? get left {
    if (widget.onRightSide) return null;
    if (widget.onLeftSide) return kNavBarWidth - AppSpacing.pageMargin;
    if (widget.tiny) return OverlayMenuContent.tinyWidth;
    if (widget.small) return OverlayMenuContent.smallWidth / 2;
    if (widget.medium) return OverlayMenuContent.mediumWidth / 20 - 100;
    return null; // Default case, can be adjusted as needed
  }

  double? get right {
    if (widget.onLeftSide) return null;
    if (widget.onRightSide) return -AppSpacing.pageMargin;
    if (widget.tiny || widget.small || widget.medium) return 0.0;
    return -AppSpacing.pageMargin; // Default case, can be adjusted as needed
  }

  double? get bottom {
    if (widget.onTopSide) return null;
    if (widget.onBottomSide) return 0;
    if (widget.tiny || widget.small || widget.medium) return 0.0;
    return -AppSpacing.pageMargin; // Default case, can be adjusted as needed
  }

  // 2. Convert your existing getters into starting positions
  double? get _initialLeft {
    return null;
    if (widget.onRightSide) return null;
    if (widget.onLeftSide) return kNavBarWidth - AppSpacing.pageMargin;
    if (widget.tiny) return OverlayMenuContent.tinyWidth;
    if (widget.small) return OverlayMenuContent.smallWidth / 2;
    if (widget.medium) return OverlayMenuContent.mediumWidth / 2;
    return null;
  }

  double? get _initialTop {
    return null;
    if (widget.onBottomSide) return null;
    if (widget.onTopSide) return MediaQuery.of(context).padding.top;
    if (widget.tiny || widget.small || widget.medium) return 0.0;
    return null;
  }

  @override
  void initState() {
    BlocProvider.of<NotificationBloc>(context).updateContext(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppSize appSize = AppSize(context);
    final bool navBarReduced = context.read<AppBloc>().state.showNavBar == false;

    // Starting positions, or fallback
    // final leftw = (_initialLeft ?? (appSize.screenWidth / 4)) + _dragOffsetX;
    // final topw = (_initialTop ?? (appSize.screenHeight / 6)) + _dragOffsetY;
    final leftw = left == null || !widget.canMove ? left : (left! + _dragOffsetX);
    final topw = top == null || !widget.canMove ? top : (top! + _dragOffsetY);
    final rightw = right == null || !widget.canMove ? right : (right! - _dragOffsetX);
    final bottomw = bottom == null || !widget.canMove ? bottom : (bottom! - _dragOffsetY);

    return Stack(
      children: [
        Positioned(
          right: rightw,
          bottom: bottomw,
          top: topw,
          left: leftw,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: GestureDetector(
              // 3. Update offsets as the user drags
              onPanUpdate: (details) {
                setState(() {
                  _dragOffsetX += details.delta.dx;
                  _dragOffsetY += details.delta.dy;
                });
              },
              child: TapRegion(
                onTapOutside: (event) {
                  if (!widget.leaveAllOpen) {
                    return;
                  }
                  // pop until first context
                  while (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: GlassContainer(
                    // opaque: true,
                    // lighter: true,
                    // roundBottomCorners: widget.tiny || widget.small || widget.medium,
                    height: (widget.tiny || widget.small || widget.medium) ? null : _height(context),
                    width: widget.width ??
                        (widget.tiny
                            ? OverlayMenuContent.tinyWidth
                            : widget.small
                                ? OverlayMenuContent.smallWidth
                                : widget.medium
                                    ? OverlayMenuContent.mediumWidth
                                    : (navBarReduced
                                        ? (appSize.screenWidth - AppSpacing.pageMargin * 2)
                                        : (appSize.screenWidth -
                                            kNavBarWidth -
                                            AppSpacing.pageMargin * 2 -
                                            AppSpacing.sectionMargin))),
                    padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: widget.width ?? 0.0,
                        maxHeight: _height(context), // Set a maximum height for the overlay
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Positioned(
        //   top: 0,
        //   left: kNavBarWidth + AppSpacing.pageMargin,
        //   child: Container(
        //     color: Colors.black54,
        //     width: appSize.screenWidth,
        //     height: AppSpacing.pageMargin * 2 + AppSpacing.elementMargin + 40 + AppSpacing.sectionMargin,
        //   ),
        // ),
      ],
    );
  }

  _height(BuildContext context) {
    final AppSize appSize = AppSize(context);
    return appSize.screenHeight -
        MediaQuery.of(context).padding.top -
        AppSpacing.pageMargin -
        40 -
        AppSpacing.sectionMargin;
  }
}
