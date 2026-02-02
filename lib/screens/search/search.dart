import 'dart:async';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/search/search_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/x_text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/search_response.dart';
import 'package:murya/screens/base.dart';
import 'package:murya/screens/ressources/resources.dart';

class MainSearchLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.searchModule];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
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
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  static const _debounceDuration = Duration(milliseconds: 550);

  String selectedFilter = '';

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final history = Beamer.of(context).beamingHistory;

      if (history.length > 1) {
        final lastBeamState = history[history.length - 2];
        final lastPath = lastBeamState.state.routeInformation.uri.path.toString(); // ← ceci est le path
        bool fromLanding = lastPath == AppRoutes.landing;
        if (!fromLanding) {
          context.read<SearchBloc>().add(SearchQueryChanged(query: "", context: context));
        }
      } else {
        context.read<SearchBloc>().add(SearchQueryChanged(query: "", context: context));
      }
      selectedFilter = AppLocalizations.of(context).search_filter_all;
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
                child: Hero(
                  tag: 'main-search-bar',
                  child: SizedBox(
                    width:
                        isMobile ? null : constraints.maxWidth / (constraints.maxWidth ~/ (340)) - AppSpacing.spacing16,
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
              const AppXCloseButton(),
            ],
          ),
          if (isMobile) AppSpacing.spacing40_Box else AppSpacing.pageMarginBox,
          Expanded(
            child: BlocConsumer<SearchBloc, SearchState>(
              listener: (context, state) {
                setState(() {});
              },
              builder: (context, state) {
                return Column(
                  children: [
                    selectorBar(isMobile, locale, theme),
                    AppSpacing.spacing40_Box,
                    Flexible(
                      child: SingleChildScrollView(
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: isMobile ? constraints.maxHeight * 4 : constraints.maxHeight * 1.125,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (selectedFilter == locale.search_filter_all ||
                                  selectedFilter == locale.search_filter_job) ...[
                                Flexible(
                                  child: JobsSearchResultsList(
                                    searchState: state,
                                    seeAll: selectedFilter == locale.search_filter_job,
                                    switchFilter: () {
                                      setState(() {
                                        selectedFilter = locale.search_filter_job;
                                        _triggerSearchForFilter(selectedFilter);
                                      });
                                    },
                                  ),
                                ),
                                if (selectedFilter == locale.search_filter_all) AppSpacing.spacing40_Box,
                              ],
                              if (selectedFilter == locale.search_filter_all ||
                                  selectedFilter == locale.search_filter_resource) ...[
                                Flexible(
                                  child: ResourcesSearchResultsList(
                                    searchState: state,
                                    seeAll: selectedFilter == locale.search_filter_resource,
                                    switchFilter: () {
                                      setState(() {
                                        selectedFilter = locale.search_filter_resource;
                                        _triggerSearchForFilter(selectedFilter);
                                      });
                                    },
                                  ),
                                ),
                                if (selectedFilter == locale.search_filter_all) AppSpacing.spacing40_Box,
                              ],
                              if (selectedFilter == locale.search_filter_all ||
                                  selectedFilter == locale.search_filter_profile) ...[
                                Flexible(
                                  child: ProfilesSearchResultsList(
                                    searchState: state,
                                    seeAll: selectedFilter == locale.search_filter_profile,
                                    switchFilter: () {
                                      setState(() {
                                        selectedFilter = locale.search_filter_profile;
                                        _triggerSearchForFilter(selectedFilter);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
      context.read<SearchBloc>().add(SearchQueryChanged(query: value, context: context));
    });
  }

  selectorBar(bool isMobile, AppLocalizations locale, ThemeData theme) {
    return Container(
      height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
      child: Row(
        children: [
          // Tout
          selectorItem(locale.search_filter_all, theme),
          AppSpacing.spacing8_Box,
          // Metier
          selectorItem(locale.search_filter_job, theme),
          AppSpacing.spacing8_Box,
          // Ressource
          selectorItem(locale.search_filter_resource, theme),
          AppSpacing.spacing8_Box,
          // Profils
          selectorItem(locale.search_filter_profile, theme),
        ],
      ),
    );
  }

  selectorItem(String title, ThemeData theme) {
    bool isSelected = title == selectedFilter;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFilter = title;
        });
        _triggerSearchForFilter(title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryFocus : Colors.transparent,
          borderRadius: AppRadius.tiny,
          border: Border.all(
            color: isSelected ? AppColors.primaryFocus : const Color(0xFFA8A8A8),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            height: 1,
            color: isSelected ? AppColors.textInverted : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  void _triggerSearchForFilter(String filter) {
    final locale = AppLocalizations.of(context);
    final query = _searchController.text;
    if (!mounted) return;
    if (filter == locale.search_filter_all) {
      context.read<SearchBloc>().add(SearchQueryChanged(query: query, context: context));
      return;
    }

    List<String> sections;
    if (filter == locale.search_filter_job) {
      sections = const ['jobs', 'jobFamilies'];
    } else if (filter == locale.search_filter_resource) {
      sections = const ['learningResources'];
    } else if (filter == locale.search_filter_profile) {
      sections = const ['users'];
    } else {
      sections = const ['jobs', 'jobFamilies', 'learningResources', 'users'];
    }

    context.read<SearchBloc>().add(SearchQueryChanged(
          query: query,
          context: context,
          limit: 30,
          sections: sections,
        ));
  }
}

class JobsSearchResultsList extends StatefulWidget {
  final SearchState searchState;
  final bool seeAll;
  final VoidCallback switchFilter;

  const JobsSearchResultsList({super.key, required this.searchState, this.seeAll = false, required this.switchFilter});

  @override
  State<JobsSearchResultsList> createState() => _JobsSearchResultsListState();
}

class _JobsSearchResultsListState extends State<JobsSearchResultsList> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final AppSize appSize = AppSize(context);
    bool isMobile = DeviceHelper.isMobile(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                locale.search_filter_job,
                style: GoogleFonts.anton(
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  height: 38 / 32,
                  letterSpacing: -0.02 * 32,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.spacing16_Box,
              if (widget.seeAll == false)
                MouseRegion(
                  onEnter: (event) {
                    _isHovering = true;
                    setState(() {});
                  },
                  onExit: (event) {
                    _isHovering = false;
                    setState(() {});
                  },
                  child: GestureDetector(
                    onTap: () {
                      widget.switchFilter();
                    },
                    child: Text(
                      locale.parcoursRewards_seeAll,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: !_isHovering ? AppButtonColors.tertiaryTextDefault : AppButtonColors.tertiaryTextHover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.spacing16_Box,
          Flexible(child: (widget.seeAll) ? fullView(appSize, theme) : previewView(appSize, theme, isMobile)),
        ],
      ),
    );
  }

  fullView(AppSize appSize, ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth / 4 - AppSpacing.spacing16, 320).toDouble();
      final items =
          widget.searchState.response.sections.jobs.items + widget.searchState.response.sections.jobFamilies.items;
      return Wrap(
        spacing: AppSpacing.spacing16,
        runSpacing: AppSpacing.spacing16 * 1.5,
        children: items.map((e) {
          return SizedBox(
            width: width,
            height: 140,
            child: AppXButton(
              height: 140,
              shrinkWrap: false,
              text: e.title,
              onPressed: () {
                // Navigate to job details
                navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', e.id));
              },
              isLoading: false,
              bgColor: AppButtonColors.secondarySurfaceDefault,
              hoverColor: AppButtonColors.secondarySurfaceHover,
              shadowColor: AppButtonColors.secondaryShadowDefault,
              borderColor: AppButtonColors.secondaryBorderDefault,
              onPressedColor: AppButtonColors.secondarySurfaceDefault,
              children: [
                Flexible(
                  child: Center(
                    child: Text(
                      e.title,
                      style: GoogleFonts.anton(
                        color: AppColors.textPrimary,
                        fontSize: theme.textTheme.headlineSmall!.fontSize,
                        fontWeight: FontWeight.w400,
                        height: 44 / theme.textTheme.headlineSmall!.fontSize!,
                        letterSpacing: -0.02 * theme.textTheme.headlineSmall!.fontSize!,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  previewView(AppSize appSize, ThemeData theme, bool isMobile) {
    final int upTo = appSize.screenWidth ~/ 320;
    final items =
        widget.searchState.response.sections.jobs.items + widget.searchState.response.sections.jobFamilies.items;
    List<SearchItem> data = items.takeUpTo(upTo);
    return LayoutBuilder(builder: (context, constraints) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 140,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: data.map((e) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 320,
                ),
                margin: EdgeInsets.only(
                  right: e != data.last ? AppSpacing.spacing16 : 0,
                  bottom: 5,
                ),
                child: AppXButton(
                  height: 140,
                  shrinkWrap: false,
                  text: e.title,
                  onPressed: () {
                    // Navigate to job details
                    navigateToPath(context, to: AppRoutes.jobDetails.replaceFirst(':id', e.id));
                  },
                  isLoading: false,
                  bgColor: AppButtonColors.secondarySurfaceDefault,
                  hoverColor: AppButtonColors.secondarySurfaceHover,
                  shadowColor: AppButtonColors.secondaryShadowDefault,
                  borderColor: AppButtonColors.secondaryBorderDefault,
                  onPressedColor: AppButtonColors.secondarySurfaceDefault,
                  children: [
                    Flexible(
                      child: Center(
                        child: Text(
                          e.title,
                          style: GoogleFonts.anton(
                            color: AppColors.textPrimary,
                            fontSize: isMobile
                                ? theme.textTheme.displayMedium!.fontSize
                                : theme.textTheme.headlineSmall!.fontSize,
                            fontWeight: FontWeight.w400,
                            height: isMobile
                                ? 44 / theme.textTheme.displayMedium!.fontSize!
                                : 44 / theme.textTheme.headlineSmall!.fontSize!,
                            letterSpacing: -0.02 *
                                (isMobile
                                    ? theme.textTheme.displayMedium!.fontSize!
                                    : theme.textTheme.headlineSmall!.fontSize!),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}

class ResourcesSearchResultsList extends StatefulWidget {
  final SearchState searchState;
  final bool seeAll;
  final VoidCallback? switchFilter;

  const ResourcesSearchResultsList({super.key, required this.searchState, this.seeAll = false, this.switchFilter});

  @override
  State<ResourcesSearchResultsList> createState() => _ResourcesSearchResultsListState();
}

class _ResourcesSearchResultsListState extends State<ResourcesSearchResultsList> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final AppSize appSize = AppSize(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                locale.search_filter_resource,
                style: GoogleFonts.anton(
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  height: 38 / 32,
                  letterSpacing: -0.02 * 32,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.spacing16_Box,
              if (widget.seeAll == false)
                MouseRegion(
                  onEnter: (event) {
                    _isHovering = true;
                    setState(() {});
                  },
                  onExit: (event) {
                    _isHovering = false;
                    setState(() {});
                  },
                  child: GestureDetector(
                    onTap: () {
                      widget.switchFilter?.call();
                    },
                    child: Text(
                      locale.parcoursRewards_seeAll,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: !_isHovering ? AppButtonColors.tertiaryTextDefault : AppButtonColors.tertiaryTextHover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.spacing16_Box,
          Flexible(child: (widget.seeAll) ? fullView(appSize) : previewView(appSize)),
        ],
      ),
    );
  }

  fullView(AppSize appSize) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth / 4 - AppSpacing.spacing16, 320 + AppSpacing.spacing16).toDouble();
      return Wrap(
        spacing: AppSpacing.spacing4,
        runSpacing: AppSpacing.spacing16,
        children: widget.searchState.response.sections.learningResources.items.map((e) {
          final resource = e.toResource();
          final index = widget.searchState.response.sections.learningResources.items.indexOf(e);
          return SizedBox(
            width: width,
            height: 300,
            child: ResourceItemWidget(resource: resource, index: index, fixedSize: true),
          );
        }).toList(),
      );
    });
  }

  previewView(AppSize appSize) {
    final int upTo = appSize.screenWidth ~/ 320;
    List<SearchItem> data = widget.searchState.response.sections.learningResources.items.takeUpTo(upTo);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 300,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: data.map((e) {
              final item = widget.searchState.response.sections.learningResources.items
                  .firstWhereOrNull((element) => element.id == e.id);
              if (item == null) {
                return const SizedBox.shrink();
              }
              final resource = item.toResource();
              final index = widget.searchState.response.sections.learningResources.items.indexOf(item);
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 320 + AppSpacing.spacing16,
                ),
                margin: EdgeInsets.only(
                  right: e != data.last ? 0 : 0,
                ),
                child: ResourceItemWidget(resource: resource, index: index, fixedSize: false),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

class ProfilesSearchResultsList extends StatefulWidget {
  final SearchState searchState;
  final bool seeAll;
  final VoidCallback? switchFilter;

  const ProfilesSearchResultsList({super.key, required this.searchState, this.seeAll = false, this.switchFilter});

  @override
  State<ProfilesSearchResultsList> createState() => _ProfilesSearchResultsListState();
}

class _ProfilesSearchResultsListState extends State<ProfilesSearchResultsList> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final AppSize appSize = AppSize(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                locale.search_filter_profile,
                style: GoogleFonts.anton(
                  fontWeight: FontWeight.w400,
                  fontSize: 32,
                  height: 38 / 32,
                  letterSpacing: -0.02 * 32,
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.spacing16_Box,
              if (widget.seeAll == false)
                MouseRegion(
                  onEnter: (event) {
                    _isHovering = true;
                    setState(() {});
                  },
                  onExit: (event) {
                    _isHovering = false;
                    setState(() {});
                  },
                  child: GestureDetector(
                    onTap: () {
                      widget.switchFilter?.call();
                    },
                    child: Text(
                      locale.parcoursRewards_seeAll,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: !_isHovering ? AppButtonColors.tertiaryTextDefault : AppButtonColors.tertiaryTextHover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.spacing16_Box,
          Flexible(child: (widget.seeAll) ? fullView(appSize, theme, locale) : previewView(appSize, theme, locale)),
        ],
      ),
    );
  }

  fullView(AppSize appSize, ThemeData theme, AppLocalizations locale) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = math.min(constraints.maxWidth / 4 - AppSpacing.spacing16, 204).toDouble();
      return Wrap(
        spacing: AppSpacing.spacing16,
        runSpacing: AppSpacing.spacing16,
        children: widget.searchState.response.sections.users.items.map((e) {
          return SizedBox(
            width: width,
            child: Column(
              children: [
                Container(
                  height: 204,
                  width: 204,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(102),
                    child: e.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: e.imageUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return SvgPicture.asset(AppIcons.avatarPlaceholderPath);
                            },
                          )
                        : SvgPicture.asset(AppIcons.avatarPlaceholderPath),
                  ),
                ),
                AppSpacing.spacing8_Box,
                Text(
                  e.title == "Utilisateur" ? locale.user_anonymous_placeholder : e.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  previewView(AppSize appSize, ThemeData theme, AppLocalizations locale) {
    final int upTo = appSize.screenWidth ~/ 204;
    List<SearchItem> data = widget.searchState.response.sections.users.items.takeUpTo(upTo);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 235,
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: data.map((e) {
              return Container(
                constraints: const BoxConstraints(
                  maxWidth: 204,
                ),
                margin: EdgeInsets.only(
                  right: e != data.last ? AppSpacing.spacing16 : 0,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 204,
                      width: 204,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(102),
                        child: e.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: e.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return SvgPicture.asset(AppIcons.avatarPlaceholderPath);
                                },
                              )
                            : SvgPicture.asset(AppIcons.avatarPlaceholderPath),
                      ),
                    ),
                    AppSpacing.spacing8_Box,
                    Text(
                      e.title == "Utilisateur" ? locale.user_anonymous_placeholder : e.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
