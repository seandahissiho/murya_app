import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/helpers.dart';
import 'package:murya/screens/competencies_family_details/competencies_family_details.dart';
import 'package:murya/screens/job_details/job_details.dart';
import 'package:murya/screens/job_evaluation/job_evaluation.dart';
import 'package:murya/screens/landing/landing.dart';
import 'package:murya/screens/dashboard/dashboard.dart';
import 'package:murya/screens/ressources/resources.dart';
import 'package:murya/screens/ressources/viewers/viewer_handler.dart';
import 'package:murya/screens/search/search.dart';

class AppRoutes {
  static const String landing = '/landing';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';

  // allModules
  static const String allModules = '/all-modules';
  static const String accountModule = '/account';
  static const String jobModule = '/job';
  static const String userRessourcesModule = '/user-ressources';
  static const String userResourceViewerModule = '/user-ressources/viewer/:id';

  // Jobs
  static const String jobDetails = '/job/:id/details';
  // competencyFamilyDetails
  static const String competencyFamilyDetails =
      '/job/:jobId/competency-family/:cfId/details';
  // jobEvaluation
  static const String jobEvaluation = '/job/:id/evaluation';

  // legalMentions
  static const String legalMentions = '/legal-mentions';
  // privacyPolicy
  static const String privacyPolicy = '/privacy-policy';
  // cookieSettings
  static const String cookieSettings = '/cookie-settings';
  // accessibility
  static const String accessibility = '/accessibility';

  static const List<String> unguardedRoutes = [
    landing,
    login,
    register,
    forgotPassword,
  ];

  static const List<String> navPaths = [
    landing,
  ];
}

const List<String> routesWithoutHeader = [
  AppRoutes.landing,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
];

List<BeamLocation<RouteInformationSerializable<dynamic>>> beamLocations = [
  LandingLocation(),
  DashboardLocation(),
  MainSearchLocation(),
  JobDetailsLocation(),
  CfDetailsLocation(),
  JobEvaluationLocation(),
  // userRessourcesModule
  RessourcesLocation(),
  ResourceViewerLocation(),
  // BaseLocation(),
  OtherLocation(), // Add other locations as needed
];

class OtherLocation
    extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => ['*'];

  @override
  List<BeamPage> buildPages(
      BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('other-$languageCode'),
        title: '404 Not Found',
        child: InkWell(
          onTap: () {
            navigateToPath(context, to: AppRoutes.landing);
          },
          child: const Center(
            child:
                Text('Page not found', style: TextStyle(color: Colors.black)),
          ),
        ),
      ),
    ];
  }
}
