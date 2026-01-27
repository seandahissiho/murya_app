import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/screens/base.dart';
import 'package:murya/screens/dashboard/dashboard_mobile.dart';

class DashboardLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.dashboard];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    // ignore: unused_local_variable
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('dashboard-${context.read<AppBloc>().appLanguage.code}'),
        title: 'Murya - Dashboard',
        child: const DashboardScreen(),
      ),
    ];
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileDashboardScreen(),
      tabletScreen: MobileDashboardScreen(), // Fallback to mobile for now
      desktopScreen: MobileDashboardScreen(), // Fallback to mobile for now
    );
  }
}
