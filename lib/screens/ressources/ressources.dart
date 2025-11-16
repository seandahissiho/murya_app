import 'package:beamer/beamer.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/screens/base.dart';

part '_ressources_mobile.dart';
part '_ressources_tablet+.dart';

class RessourcesLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.userRessourcesModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('ressources-page-$languageCode'),
        title: 'Ressources Page',
        child: const RessourcesScreen(),
      ),
    ];
  }
}

class RessourcesScreen extends StatelessWidget {
  const RessourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileRessourcesScreen(),
      tabletScreen: TabletRessourcesScreen(),
      desktopScreen: TabletRessourcesScreen(),
    );
  }
}
