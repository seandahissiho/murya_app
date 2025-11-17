import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/quizz/quiz_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/score.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/models/quiz.dart';
import 'package:murya/repositories/base.repository.dart';
import 'package:murya/screens/base.dart';

part '_job_evaluation_mobile.dart';
part '_job_evaluation_tablet+.dart';

class JobEvaluationLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.jobEvaluation];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('jobEvaluation-page-$languageCode'),
        title: 'JobEvaluation Page',
        child: const JobEvaluationScreen(),
      ),
    ];
  }
}

class JobEvaluationScreen extends StatelessWidget {
  const JobEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileJobEvaluationScreen(),
      tabletScreen: TabletJobEvaluationScreen(),
      desktopScreen: TabletJobEvaluationScreen(),
    );
  }
}
