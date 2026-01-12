import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/screens/base.dart';

part '_profile_mobile.dart';
part '_profile_tablet+.dart';

class ProfileLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.profile];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('profile-page-$languageCode'),
        title: 'Profile',
        child: const ProfileScreen(),
      ),
    ];
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileProfileScreen(),
      tabletScreen: TabletProfileScreen(),
      desktopScreen: TabletProfileScreen(),
    );
  }
}
