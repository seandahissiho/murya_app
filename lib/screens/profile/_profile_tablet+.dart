part of 'profile.dart';

class TabletProfileScreen extends StatefulWidget {
  const TabletProfileScreen({super.key});

  @override
  State<TabletProfileScreen> createState() => _TabletProfileScreenState();
}

class _TabletProfileScreenState extends State<TabletProfileScreen> {
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
            const Row(
              children: [
                Spacer(),
                AppXCloseButton(),
              ],
            ),
            Row(
              children: [
                RichText(
                  text: TextSpan(
                    text: AppLocalizations.of(context).parcoursPageTitle,
                    style: GoogleFonts.anton(
                      color: AppColors.textPrimary,
                      fontSize: theme.textTheme.headlineMedium?.fontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.sectionMarginBox,
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
              isScrollable: true,
              labelColor: AppColors.primaryDefault,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryDefault,
              tabs: [
                Tab(text: AppLocalizations.of(context).parcoursTab_profile),
                Tab(text: AppLocalizations.of(context).parcoursTab_objectives),
                Tab(text: AppLocalizations.of(context).parcoursTab_rewards),
                Tab(text: AppLocalizations.of(context).parcoursTab_settings),
              ],
            ),
          ),
          AppSpacing.elementMarginBox,
          Expanded(
            child: TabBarView(
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

class TabletJourneyInfoTab extends StatefulWidget {
  const TabletJourneyInfoTab({super.key});

  @override
  State<TabletJourneyInfoTab> createState() => _TabletJourneyInfoTabState();
}

class _TabletJourneyInfoTabState extends State<TabletJourneyInfoTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return const Placeholder();
  }
}

class TabletJourneyObjectivesTab extends StatefulWidget {
  const TabletJourneyObjectivesTab({super.key});

  @override
  State<TabletJourneyObjectivesTab> createState() =>
      _TabletJourneyObjectivesTabState();
}

class _TabletJourneyObjectivesTabState
    extends State<TabletJourneyObjectivesTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return const Placeholder();
  }
}

class TabletJourneyRewardsTab extends StatefulWidget {
  const TabletJourneyRewardsTab({super.key});

  @override
  State<TabletJourneyRewardsTab> createState() =>
      _TabletJourneyRewardsTabState();
}

class _TabletJourneyRewardsTabState extends State<TabletJourneyRewardsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return const Placeholder();
  }
}

class TabletJourneySettingsTab extends StatefulWidget {
  const TabletJourneySettingsTab({super.key});

  @override
  State<TabletJourneySettingsTab> createState() =>
      _TabletJourneySettingsTabState();
}

class _TabletJourneySettingsTabState extends State<TabletJourneySettingsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return const Placeholder();
  }
}
