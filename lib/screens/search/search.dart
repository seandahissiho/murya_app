import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/x_text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/screens/base.dart';

class MainSearchLocation
    extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.jobModule];

  @override
  List<BeamPage> buildPages(
      BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('main-search-page-$languageCode'),
        title: 'Murya - Recherche',
        child: const MainSearchScreen(),
        routeBuilder: (context, settings, child) {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) => child,
            transitionDuration: const Duration(milliseconds: 1600),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        mobileScreen: searchScreen(),
        tabletScreen: searchScreen(),
        desktopScreen: searchScreen());
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
                child: Hero(
                  tag: 'main-search-bar',
                  child: SizedBox(
                    width: isMobile
                        ? null
                        : constraints.maxWidth /
                                (constraints.maxWidth ~/ (340)) -
                            AppSpacing.spacing16,
                    child: AppXTextFormField(
                      labelText: null,
                      hintText: locale.search_placeholder,
                      prefixIconPath: AppIcons.homeSearchIcon2Path,
                      controller: _searchController,
                      focusNode: focusNode,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),
              ),
              AppSpacing.spacing16_Box,
              // const Spacer(),
              const AppXCloseButton(),
            ],
          ),
          if (isMobile) AppSpacing.spacing40_Box else AppSpacing.pageMarginBox,
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
                    mainAxisSpacing:
                        isMobile ? AppSpacing.spacing8 : AppSpacing.spacing16,
                    crossAxisSpacing:
                        isMobile ? AppSpacing.spacing8 : AppSpacing.spacing16,
                    childAspectRatio: isMobile ? 1.618 : 2.42857143,
                  ),
                  itemCount: state.jobs.length,
                  itemBuilder: (context, index) {
                    final job = state.jobs[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          navigateToPath(
                            context,
                            to: AppRoutes.jobDetails.replaceAll(':id', job.id!),
                            data: {'jobTitle': job.title},
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.backgroundInverted),
                            color: AppColors.backgroundInverted,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              job.title,
                              textAlign: TextAlign.center,
                              style: (isMobile
                                      ? theme.textTheme.labelLarge!
                                      : theme.textTheme.displayMedium!)
                                  .copyWith(
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
                  spacing: AppSpacing.spacing8,
                  runSpacing: AppSpacing.spacing8,
                  children: state.jobs.map((module) {
                    return SizedBox(
                      width: DeviceHelper.isMobile(context) ? 140 : 314,
                      height: 140,
                      child: Card(
                        child: Center(
                          child: Text(module.id!),
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
