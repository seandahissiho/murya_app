part of 'profile.dart';

class TabletProfileScreen extends StatefulWidget {
  const TabletProfileScreen({super.key});

  @override
  State<TabletProfileScreen> createState() => _TabletProfileScreenState();
}

class _TabletProfileScreenState extends State<TabletProfileScreen> {
  int hoveredTabIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: AppLocalizations.of(context).parcoursPageTitle,
                      style: GoogleFonts.anton(
                        color: AppColors.textPrimary,
                        fontSize: theme.textTheme.headlineMedium?.fontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const AppXCloseButton(),
              ],
            ),
            AppSpacing.spacing16_Box,
            Expanded(
              child: _tabs(theme, locale),
            ),
          ],
        );
      },
    );
  }

  /*
  SingleChildScrollView(
                child: AppSkeletonizer(
                  enabled: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
                  ),
                ),
              )
   */

  _tabs(ThemeData theme, AppLocalizations locale) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              onHover: (value, index) {
                if (value) {
                  hoveredTabIndex = index;
                } else {
                  hoveredTabIndex = -1;
                }
                setState(() {});
              },
              isScrollable: true,
              tabs: [
                Tab(
                  child: Text(
                    AppLocalizations.of(context).parcoursTab_profile,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: hoveredTabIndex == 0 ? AppColors.primaryFocus : AppColors.textPrimary,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context).parcoursTab_objectives,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: hoveredTabIndex == 1 ? AppColors.primaryFocus : AppColors.textPrimary,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context).parcoursTab_rewards,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: hoveredTabIndex == 2 ? AppColors.primaryFocus : AppColors.textPrimary,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context).parcoursTab_settings,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: hoveredTabIndex == 3 ? AppColors.primaryFocus : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Expanded(
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                TabletJourneyInfoTab(),
                TabletJourneyObjectivesTab(),
                TabletJourneyRewardsTab(),
                TabletJourneySettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
