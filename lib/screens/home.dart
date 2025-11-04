import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';

class HomeLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.home];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('home-page-$languageCode'),
        title: 'Home',
        child: const HomeScreen(),
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
