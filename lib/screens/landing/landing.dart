import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:blobs/blobs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/components/app_footer.dart';
import 'package:murya/components/app_module.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/module.dart';
import 'package:murya/screens/app_bar/app_bar.dart';
import 'package:murya/screens/base.dart';

part '_landing_mobile.dart';
part '_landing_tablet+.dart';

class LandingLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.landing];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('landing-page-$languageCode'),
        title: 'Landing Page',
        child: const LandingScreen(),
      ),
    ];
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileLandingScreen(),
      tabletScreen: TabletLandingScreen(),
      desktopScreen: TabletLandingScreen(),
    );
  }
}

class AddModuleButton extends StatelessWidget {
  const AddModuleButton({super.key});

  static const _colors = [
    // #5F27CD
    Color(0xFF5F27CD),
    // #9159E5
    Color(0xFF9159E5),
    // #C26BFF
    Color(0xFFC26BFF),
    // #FF4100
    Color(0xFFFF4100),
    // #49B86C
    Color(0xFF49B86C),
    // #05E7D2
    Color(0xFF05E7D2),
    // #8CD9E5
    Color(0xFF8CD9E5),
    // #3ED20D
    Color(0xFF3ED20D),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = DeviceHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile
            ? AppSpacing.pageMargin + MediaQuery.of(context).padding.bottom
            : AppSpacing.pageMargin + AppSpacing.sectionMargin,
      ),
      child: Blob.animatedRandom(
        size: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 27,
        edgesCount: 8,
        minGrowth: 3,
        duration: const Duration(milliseconds: 1000),
        loop: true,
        styles: BlobStyles(
          // color: Colors.red,
          gradient: const LinearGradient(
            colors: _colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(const Rect.fromLTRB(0, 0, 85, 85)),
          fillType: BlobFillType.fill,
          strokeWidth: 3,
        ),
        child: Center(
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 10,
              height: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 10,
              margin: const EdgeInsets.only(top: 10, left: 10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
