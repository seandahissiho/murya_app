import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/components/text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/screens/base.dart';

class MainSearchLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.searchModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    return [
      const BeamPage(
        key: ValueKey('main-search'),
        title: 'Main Search',
        child: MainSearchScreen(),
      ),
    ];
  }
}

class MainSearchScreen extends StatefulWidget {
  const MainSearchScreen({super.key});

  @override
  State<MainSearchScreen> createState() => _MainSearchScreenState();
}

class _MainSearchScreenState extends State<MainSearchScreen> {
  final FocusNode focusNode = FocusNode();
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 250);

  @override
  initState() {
    context.read<JobBloc>().add(SearchJobs(query: "", context: context));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    // ✨ Clean up
    _debounce?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(mobileScreen: searchScreen(), tabletScreen: searchScreen(), desktopScreen: searchScreen());
  }

  searchScreen() {
    final locale = AppLocalizations.of(context);
    bool isMobile = DeviceHelper.isMobile(context);
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 10,
                child: AppTextFormField(
                  label: null,
                  autoResize: false,
                  leadingIcon: AppIcons.homeSearchIcon2Path,
                  hintText: locale.search_placeholder,
                  focusNode: focusNode,
                  onChanged: _onSearchChanged,
                  width:
                      isMobile ? null : constraints.maxWidth / (constraints.maxWidth ~/ (340)) - AppSpacing.groupMargin,
                ),
              ),
              AppSpacing.groupMarginBox,
              // const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                      return;
                    }
                    navigateToPath(context, to: AppRoutes.landing);
                  },
                  child: SvgPicture.asset(
                    AppIcons.searchBarCloseIconPath,
                    width: isMobile ? 32 : 40,
                    height: isMobile ? 32 : 40,
                  ),
                ),
              )
            ],
          ),
          if (isMobile) AppSpacing.sectionMarginBox else AppSpacing.pageMarginBox,
          Expanded(
            child: BlocConsumer<JobBloc, JobState>(
              listener: (context, state) {
                setState(() {});
              },
              builder: (context, state) {
                return GridView.builder(
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 2 : constraints.maxWidth ~/ 340,
                    mainAxisSpacing: isMobile ? AppSpacing.elementMargin : AppSpacing.groupMargin,
                    crossAxisSpacing: isMobile ? AppSpacing.elementMargin : AppSpacing.groupMargin,
                    childAspectRatio: isMobile ? 1.618 : 2.42857143,
                  ),
                  itemCount: state.jobs.length,
                  itemBuilder: (context, index) {
                    final job = state.jobs[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          navigateToPath(context, to: AppRoutes.jobDetails.replaceAll(':id', job.id));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.blackSwatch),
                            color: AppColors.blackSwatch,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              job.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.whiteSwatch,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
                return Wrap(
                  spacing: AppSpacing.elementMargin,
                  runSpacing: AppSpacing.elementMargin,
                  children: state.jobs.map((module) {
                    return SizedBox(
                      width: DeviceHelper.isMobile(context) ? 140 : 314,
                      height: 140,
                      child: Card(
                        child: Center(
                          child: Text(module.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ],
      );
    });
  }

  void _onSearchChanged(String value) {
    // cancel previous timer
    _debounce?.cancel();
    // schedule a new one
    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      context.read<JobBloc>().add(SearchJobs(query: value, context: context));
    });
  }
}
