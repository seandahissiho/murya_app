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
      length: 3,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: AppLocalizations.of(context).parcoursTab_profile),
                Tab(text: AppLocalizations.of(context).parcoursTab_objectives),
                Tab(text: AppLocalizations.of(context).parcoursTab_rewards),
                // Tab(text: AppLocalizations.of(context).parcoursTab_settings),
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
                // TabletJourneySettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
