part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {
  final StreamManager<List<AppNotification>>? notificationStream;
  final List<AppNotification>? notifications;
  final List<AppNotificationCategory> categories;
  final int page;
  final int totalPages;
  final int unreadCount;

  const NotificationState({
    this.notificationStream,
    this.notifications,
    this.categories = const [],
    this.page = 1,
    this.totalPages = 0,
    this.unreadCount = 0,
  });
}

class NotificationInitial extends NotificationState {}

class NotificationInitialized extends NotificationState {
  const NotificationInitialized({
    required super.notificationStream,
    required super.notifications,
    required super.categories,
    required super.page,
    required super.totalPages,
    required super.unreadCount,
  });
}

class NewNotificationState extends NotificationState {
  final AppNotification notification;
  final bool isImportant;
  final BuildContext context;
  final OverlayState? overlay;

  NewNotificationState({
    required this.overlay,
    required this.context,
    required this.notification,
    super.notificationStream,
    super.notifications,
    super.page,
    super.totalPages,
    this.isImportant = false,
    required super.unreadCount,
  }) {
    if (notification.body.contains('inconnu')) return;
    showNotification(context);
  }

  void showNotification(BuildContext context) {
    if (context.mounted == false) return;
    // if (BeamerProvider.of(context) == null) return;
    final BeamerDelegate beamerDelegate = Beamer.of(context);
    final theme = Theme.of(context);
    final AppSize size = AppSize(context);

    final overlay = beamerDelegate.navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // _current?.remove();

    bool isMobile = DeviceHelper.isMobile(context);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => SafeArea(
        top: true,
        child: Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(minHeight: 50, maxHeight: 150, maxWidth: isMobile ? 70.w : 30.w),
              decoration: BoxDecoration(
                color: AppColors.whiteSwatch,
                borderRadius: AppRadius.medium,
                border: Border.all(
                  color: AppColors.blackSwatch.shade400,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.containerInsideMargin / 2,
                horizontal: AppSpacing.containerInsideMargin,
              ),
              margin: EdgeInsets.only(
                top: isMobile ? 0 : AppSpacing.pageMargin,
                bottom: AppSpacing.pageMargin,
                left: AppSpacing.containerInsideMargin,
                right: AppSpacing.containerInsideMargin,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      AppSpacing.elementMarginBox,
                      InkWell(
                        onTap: () {
                          if (entry.mounted) entry.remove();
                          // if (identical(_current, entry)) _current = null;
                        },
                        child: SvgPicture.asset(
                          AppIcons.clearIconPath,
                          colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcATop),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.elementMarginBox,
                  Text(
                    notification.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    // _current = entry;

    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) entry.remove();
      // if (identical(_current, entry)) _current = null;
    });
    // app not ready yet

    // final overlay = Overlay.of(context);
    //
    // final overlayEntry = OverlayEntry(
    //   builder: (context) => Positioned(
    //     top: 20,
    //     right: 20,
    //     child: Material(
    //       color: Colors.transparent,
    //       child: Container(
    //         width: double.infinity,
    //         constraints: BoxConstraints(minHeight: 50, maxHeight: 150, maxWidth: 30.w),
    //         decoration: BoxDecoration(
    //           color: AppColors.backgroundColor,
    //           borderRadius: AppRadius.medium,
    //           border: Border.all(
    //             color: AppColors.whiteSwatch.shade400,
    //             width: 1.5,
    //           ),
    //         ),
    //         padding: const EdgeInsets.symmetric(
    //           vertical: AppSpacing.containerInsideMargin / 2,
    //           horizontal: AppSpacing.containerInsideMargin,
    //         ),
    //         margin: EdgeInsets.only(
    //           bottom: AppSpacing.pageMargin,
    //           left: AppSpacing.containerInsideMargin,
    //           right: AppSpacing.containerInsideMargin,
    //         ),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Row(
    //               children: [
    //                 Expanded(
    //                   child: Text(
    //                     notification.title,
    //                     style: theme.textTheme.labelLarge,
    //                   ),
    //                 ),
    //                 AppSpacing.elementMarginBox,
    //                 InkWell(
    //                   onTap: () {},
    //                   child: SvgPicture.asset(
    //                     'assets/icons/close.svg',
    //                     colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcATop),
    //                     width: 20,
    //                     height: 20,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             AppSpacing.elementMarginBox,
    //             Text(
    //               notification.body,
    //               maxLines: 3,
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    //
    // overlay.insert(overlayEntry);
    //
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (overlayEntry.mounted) {
    //     overlayEntry.remove();
    //   }
    // });
  }
}

// class NotificationOverlay {
//   static OverlayEntry? _current;
//
//   static void show(AppNotification n, {Duration duration = const Duration(seconds: 3)}) {
//     final overlay = beamerDelegate.navigatorKey.currentState?.overlay;
//     if (overlay == null) return; // app not ready yet
//
//     _current?.remove();
//
//     late final OverlayEntry entry;
//     entry = OverlayEntry(
//       builder: (context) => SafeArea(
//         child: Positioned(
//           top: 20,
//           right: 20,
//           child: Material(
//             color: Colors.transparent,
//             child: _NotificationCard(
//               notification: n,
//               onClose: () {
//                 if (entry.mounted) entry.remove();
//                 if (identical(_current, entry)) _current = null;
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//
//     overlay.insert(entry);
//     _current = entry;
//
//     Future.delayed(duration, () {
//       if (entry.mounted) entry.remove();
//       if (identical(_current, entry)) _current = null;
//     });
//   }
// }

class NewWebHookNotificationState extends NotificationState {
  const NewWebHookNotificationState({
    required super.notifications,
    super.notificationStream,
    super.page,
    super.totalPages,
    required super.unreadCount,
  });
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required super.notificationStream,
    required super.notifications,
    required super.categories,
    required super.page,
    required super.totalPages,
    required super.unreadCount,
  });
}

class NotificationsLoading extends NotificationState {
  const NotificationsLoading({
    required super.notificationStream,
    required super.notifications,
    required super.categories,
    required super.page,
    required super.totalPages,
    required super.unreadCount,
  });
}
