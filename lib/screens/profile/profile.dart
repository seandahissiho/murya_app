import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/quests/quests_bloc.dart';
import 'package:murya/blocs/modules/rewards/rewards_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/dropdown.dart';
import 'package:murya/components/ranking.dart';
import 'package:murya/components/score.dart';
import 'package:murya/components/skeletonizer.dart';
import 'package:murya/components/x_text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/Job.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/diploma.dart';
import 'package:murya/models/job_kiviat.dart';
import 'package:murya/models/module.dart';
import 'package:murya/models/preview_competency_profile.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/models/reward.dart';
import 'package:murya/screens/base.dart';
import 'package:murya/screens/job_details/job_details.dart';
import 'package:murya/screens/profile/tablet+/quest_map.dart';

part '_profile_mobile.dart';
part '_profile_tablet+.dart';
part 'tablet+/_objectives.dart';
part 'tablet+/_profils.dart';
part 'tablet+/_rewards.dart';
part 'tablet+/_settings.dart';

class ProfileLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.profile];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('profile-page-$languageCode'),
        title: 'Murya - Profile',
        child: const ProfileScreen(),
      ),
    ];
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _loadedJobId;

  @override
  void initState() {
    super.initState();
    final jobBloc = context.read<JobBloc>();
    final jobId = _resolveJobId(jobBloc.state.userCurrentJob);
    if (jobId != null) {
      _dispatchLeaderboard(jobId);
    } else {
      jobBloc.add(LoadUserCurrentJob(context: context));
    }
  }

  String? _resolveJobId(UserJob? userJob) {
    final jobId = userJob?.jobId;
    if (jobId != null && jobId.isNotEmpty) {
      return jobId;
    }
    final jobFamilyId = userJob?.jobFamilyId;
    if (jobFamilyId != null && jobFamilyId.isNotEmpty) {
      return jobFamilyId;
    }
    return null;
  }

  void _dispatchLeaderboard(String jobId) {
    if (jobId.isEmpty) return;
    if (_loadedJobId == jobId) return;
    _loadedJobId = jobId;
    context.read<ProfileBloc>().add(ProfileLoadLeaderboardEvent(jobId: jobId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobBloc, JobState>(
      listenWhen: (previous, current) => previous.userCurrentJob?.id != current.userCurrentJob?.id,
      listener: (context, state) {
        final jobId = _resolveJobId(state.userCurrentJob);
        if (jobId != null) {
          _dispatchLeaderboard(jobId);
        }
      },
      child: const BaseScreen(
        mobileScreen: MobileProfileScreen(),
        tabletScreen: TabletProfileScreen(),
        desktopScreen: TabletProfileScreen(),
      ),
    );
  }
}
