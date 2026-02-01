import 'package:flutter/material.dart';
import 'package:murya/config/DS.dart';

// class BaseLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
//   @override
//   List<String> get pathPatterns => [AppRoutes.landing];
//
//   @override
//   List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
//     final String path = (context.read<AppBloc>().state).newRoute;
//     context.read<NotificationBloc>().updateContext(context);
//     final languageCode = context.read<AppBloc>().appLanguage.code;
//
//     return [
//       BeamPage(
//         key: ValueKey('${_getKey(context, path)}-$languageCode'),
//         title: _getTitle(context, path),
//         child: _getChild(context, path),
//       ),
//     ];
//   }
//
//   String _getKey(BuildContext context, String path) {
//     final String key = path;
//     return 'home-$key';
//   }
//
//   String _getTitle(BuildContext context, String path) {
//     switch (path) {
//       case AppRoutes.home:
//         return 'Home';
//       case AppRoutes.searchModule:
//         return 'Main Search';
//       default:
//         return 'Home';
//     }
//   }
//
//   Widget _getChild(BuildContext context, String path) {
//     switch (path) {
//       case AppRoutes.landing:
//         return const LandingScreen();
//       case AppRoutes.home:
//         return const HomeScreen();
//       case AppRoutes.searchModule:
//         return const MainSearchScreen();
//       default:
//         return InkWell(
//           onTap: () {
//             navigateToPath(context, to: AppRoutes.home);
//           },
//           child: const Center(child: Text('Home Screen')),
//         );
//     }
//   }
// }

class BaseScreen extends StatefulWidget {
  final Widget? mobileScreen;
  final Widget? tabletScreen;
  final Widget? desktopScreen;
  final bool useBackgroundColor;
  final bool noPadding;

  const BaseScreen({
    super.key,
    required this.mobileScreen,
    required this.tabletScreen,
    required this.desktopScreen,
    this.useBackgroundColor = true,
    this.noPadding = false,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceType = DeviceHelper.getDeviceType(context);
    Widget body = Container();

    switch (deviceType) {
      case DeviceType.mobile:
        body = SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: widget.noPadding
                ? EdgeInsetsGeometry.zero
                : const EdgeInsets.only(
                    top: AppSpacing.pageMargin,
                    left: AppSpacing.pageMargin,
                    right: AppSpacing.pageMargin,
                    bottom: AppSpacing.spacing8,
                  ),
            child: widget.mobileScreen ?? Container(),
          ),
        );
      case DeviceType.tablet:
        body = SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: widget.noPadding
                  ? EdgeInsetsGeometry.zero
                  : const EdgeInsets.only(
                      top: AppSpacing.pageMargin,
                      left: AppSpacing.pageMargin * 2,
                      right: AppSpacing.pageMargin * 2,
                      bottom: AppSpacing.pageMargin,
                    ),
              child: widget.tabletScreen ?? widget.desktopScreen ?? Container(),
            ));
      case DeviceType.desktop:
        body = SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: widget.noPadding
                  ? EdgeInsetsGeometry.zero
                  : const EdgeInsets.only(
                      top: AppSpacing.pageMargin,
                      left: AppSpacing.pageMargin * 2,
                      right: AppSpacing.pageMargin * 2,
                      bottom: AppSpacing.pageMargin,
                    ),
              child: widget.desktopScreen ?? widget.tabletScreen ?? Container(),
            ));
      default:
        body = SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: widget.noPadding
                  ? EdgeInsetsGeometry.zero
                  : const EdgeInsets.only(
                      top: AppSpacing.pageMargin,
                      left: AppSpacing.pageMargin * 3,
                      right: AppSpacing.pageMargin * 3,
                      bottom: AppSpacing.pageMargin,
                    ),
              child: widget.desktopScreen ?? widget.tabletScreen ?? Container(),
            ));
    }

    return Container(
      color: widget.useBackgroundColor ? AppColors.backgroundColor : null,
      child: body,
    );
  }
}
