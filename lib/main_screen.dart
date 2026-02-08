import 'dart:async';
import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/components/auth_loading_bar.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/realtime/realtime_coordinator.dart';
import 'package:murya/realtime/sse_service.dart';

class AppScaffold extends StatefulWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> with WidgetsBindingObserver {
  late final RealtimeCoordinator _realtimeCoordinator;

  get _isAuthPath {
    final state = context.read<AppBloc>().state;
    final path = (state).newRoute;
    return path.startsWith(AppRoutes.login) ||
        path.startsWith(AppRoutes.register) ||
        path.startsWith(AppRoutes.forgotPassword);
  }

  bool get _isNavPath {
    final state = context.read<AppBloc>().state;
    final path = (state).newRoute;
    for (final navPath in AppRoutes.navPaths) {
      if (path.startsWith(navPath)) {
        return true;
      }
    }
    return false;
  }

  get _isMainDashboardPath {
    final state = context.read<AppBloc>().state;
    final path = (state).newRoute;
    return path.startsWith(AppRoutes.landing);
  }

  @override
  void initState() {
    context.read<AuthenticationBloc>().updateRepositoriesContext(context);
    context.read<NotificationBloc>().updateContext(context);
    final sseService = context.read<SseService>();
    _realtimeCoordinator = RealtimeCoordinator(
      context: context,
      sseService: sseService,
      authenticationBloc: context.read<AuthenticationBloc>(),
      profileBloc: context.read<ProfileBloc>(),
      resourcesBloc: context.read<ResourcesBloc>(),
      notificationBloc: context.read<NotificationBloc>(),
    );
    _realtimeCoordinator.start();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<AppBloc>().updateScreenSafeAreaPadding(context);
      context.read<AppBloc>().smt(context);
      int count = 0;
      // wait until the authentication bloc is initialized
      while (!context.read<AuthenticationBloc>().initialized) {
        if (count++ > 50) {
          log('Authentication bloc initialization timed out.');
          break; // Exit the loop after 5 seconds
        }
        await Future.delayed(const Duration(milliseconds: 250));
        if (!mounted || !context.mounted) return; // Exit if the widget is not mounted
      }
      if (!mounted || !context.mounted) return; // Exit if the widget is not mounted
      context.read<AuthenticationBloc>().updateRepositoriesContext(context);
    });
  }

  @override
  void dispose() {
    _realtimeCoordinator.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // if (_debounce?.isActive ?? false) _debounce?.cancel();
    // _debounce = Timer(const Duration(milliseconds: 50), () {
    //   setState(() {});
    // });
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, authState) {
        if (authState is Authenticated && authState.justLoggedIn) {
          context.read<AppBloc>().add(
                AppChangeRoute(
                  currentRoute: AppRoutes.login,
                  nextRoute: AppRoutes.landing,
                ),
              );
          _redirectUser(context, authState);
        }
      },
      builder: (context, authState) {
        return BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            setState(() {});
          },
          builder: (context, appState) {
            if (_isMainDashboardPath) {
              // log('At main dashboard path: ${appState.newRoute}');
            }
            return Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  if (authState is AuthenticationLoading && authState.isAuthenticated == false) {
                    return const Center(
                      child: AuthLoadingBar(),
                    );
                  }
                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: widget.child,
                            ),
                          ],
                        ),
                        // if (authState is AuthenticationLoading && authState.isAuthenticated == false) ...[
                        //   const Center(
                        //     child: CupertinoActivityIndicator(
                        //       color: Colors.black,
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  void _redirectUser(BuildContext context, Authenticated state) {
    final User user = context.read<ProfileBloc>().user;
    String? newRoute;

    // if (newRoute != null) {
    //   context.read<AppBloc>().add(
    //         AppChangeRoute(
    //           currentRoute: AppRoutes.login,
    //           nextRoute: newRoute,
    //         ),
    //       );
    // }

    if (state.isAuthenticated) {
      final currentPath = Beamer.of(context).currentBeamLocation.state.routeInformation.uri.path;
      final isAuthOrLanding = currentPath.startsWith(AppRoutes.landing) ||
          currentPath.startsWith(AppRoutes.login) ||
          currentPath.startsWith(AppRoutes.register) ||
          currentPath.startsWith(AppRoutes.forgotPassword);
      if (isAuthOrLanding) {
        Beamer.of(context).beamToNamed(AppRoutes.landing);
      }
      return;
    }

    context.read<AppBloc>().add(
          AppChangeRoute(
            currentRoute: AppRoutes.landing,
            nextRoute: AppRoutes.landing,
          ),
        );
    Beamer.of(context).beamToNamed(AppRoutes.landing);
  }
}

// class NotificationWidget extends StatefulWidget {
//   const NotificationWidget({super.key});
//
//   @override
//   State<NotificationWidget> createState() => _NotificationWidgetState();
// }
//
// class _NotificationWidgetState extends State<NotificationWidget> {
//   List<Pair<AppNotification, DateTime>> notifications = [];
//   Timer? timer;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return BlocConsumer<NotificationBloc, NotificationState>(
//       listener: (context, state) {
//         if (state is NewNotificationState && state.notification.body.isNotEmpty) {
//           if (notifications.isEmpty) {
//             autoRemoval();
//           }
//           notifications.add(Pair(state.notification, DateTime.now()));
//           // sort notifications by date Descending
//           notifications.sort((a, b) => b.second.compareTo(a.second));
//         }
//         setState(() {
//           // Update the state to reflect new notifications
//         });
//       },
//       builder: (context, state) {
//         return SizedBox(
//           width: kNavBarWidth * 1.5,
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: notifications.map((pair) {
//                 int index = notifications.indexOf(pair);
//                 final notification = notifications[index];
//                 return _notificationTile(
//                   notification: notification.first,
//                   onDismissed: () {
//                     setState(() {
//                       notifications.removeAt(index);
//                       if (notifications.isEmpty) {
//                         timer?.cancel();
//                         timer = null; // Stop the timer when no notifications are left
//                       }
//                     });
//                   },
//                   theme: theme,
//                 );
//               }).toList(),
//             ),
//           ),
//           // child: ListView.builder(
//           //   shrinkWrap: true,
//           //   itemCount: notifications.length,
//           //   itemBuilder: (context, index) {
//           //     final notification = notifications[index];
//           //     return Padding(
//           //       padding: EdgeInsets.only(
//           //         top: AppSpacing.containerInsideMargin,
//           //         bottom: AppSpacing.containerInsideMargin + AppSpacing.pageMargin,
//           //         left: AppSpacing.containerInsideMargin,
//           //         right: AppSpacing.containerInsideMargin,
//           //       ),
//           //       child: ListTile(
//           //         title: Text(notification.first.title),
//           //         subtitle: Text(notification.first.body),
//           //         trailing: IconButton(
//           //           icon: const Icon(Icons.close),
//           //           onPressed: () {
//           //             // Handle notification dismissal
//           //             notifications.removeAt(index);
//           //           },
//           //         ),
//           //       ),
//           //     );
//           //   },
//           // ),
//         );
//       },
//     );
//   }
//
//   Widget _notificationTile({
//     required AppNotification notification,
//     required VoidCallback onDismissed,
//     required ThemeData theme,
//   }) {
//     return Container(
//       width: double.infinity,
//       constraints: const BoxConstraints(minHeight: 150, maxHeight: 250),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: AppRadius.medium,
//         border: Border.all(
//           color: AppColors.whiteSwatch.shade400,
//           width: 1.5,
//         ),
//       ),
//       padding: const EdgeInsets.symmetric(
//         vertical: AppSpacing.containerInsideMargin / 2,
//         horizontal: AppSpacing.containerInsideMargin,
//       ),
//       margin: const EdgeInsets.only(
//         bottom: AppSpacing.pageMargin,
//         left: AppSpacing.containerInsideMargin,
//         right: AppSpacing.containerInsideMargin,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   notification.title,
//                   style: theme.textTheme.labelLarge,
//                 ),
//               ),
//               AppSpacing.elementMarginBox,
//               InkWell(
//                 onTap: onDismissed,
//                 child: SvgPicture.asset(
//                   'assets/icons/close.svg',
//                   colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcATop),
//                   width: 20,
//                   height: 20,
//                 ),
//               ),
//             ],
//           ),
//           AppSpacing.elementMarginBox,
//           Text(
//             notification.body,
//             maxLines: 3,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
//
//   autoRemoval() {
//     // Run every second to check for expired notifications
//     timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       final now = DateTime.now();
//       if (mounted == false || context.mounted == false) {
//         timer?.cancel();
//         timer = null; // Stop the timer if the widget is not mounted
//         return;
//       }
//       setState(() {
//         notifications.removeWhere((pair) => now.difference(pair.second).inSeconds >= 5);
//       });
//       if (notifications.isEmpty) {
//         timer?.cancel();
//         timer = null; // Stop the timer when no notifications are left
//       }
//     });
//   }
// }
