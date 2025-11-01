import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:murya/config/routes.dart';

class HomeLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.home];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [
      const BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
    ];
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
