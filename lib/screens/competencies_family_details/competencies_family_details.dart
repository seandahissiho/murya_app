import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/screens/base.dart';

part '_competencies_family_details_mobile.dart';
part '_competencies_family_details_tablet+.dart';

class CfDetailsLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.competencyFamilyDetails];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('cfDetails-page-$languageCode'),
        title: 'CfDetails Page',
        child: const CfDetailsScreen(),
      ),
    ];
  }
}

class CfDetailsScreen extends StatelessWidget {
  const CfDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileCfDetailsScreen(),
      tabletScreen: TabletCfDetailsScreen(),
      desktopScreen: TabletCfDetailsScreen(),
    );
  }
}
