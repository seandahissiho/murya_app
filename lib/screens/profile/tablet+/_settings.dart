part of '../profile.dart';

class TabletJourneySettingsTab extends StatefulWidget {
  const TabletJourneySettingsTab({super.key});

  @override
  State<TabletJourneySettingsTab> createState() => _TabletJourneySettingsTabState();
}

class _TabletJourneySettingsTabState extends State<TabletJourneySettingsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppSpacing.spacing16_Box,
            Text(
              locale.profile_account_title,
              // font-family: Anton;
              // font-style: Regular;
              style: GoogleFonts.anton(
                color: AppColors.primaryDefault,
                // font-size: 32px;
                fontSize: theme.textTheme.headlineSmall?.fontSize,
                // font-weight: 400;
                fontWeight: FontWeight.w400,
                // letter-spacing: -2%;
                letterSpacing: -0.02,
                // line-height: 38px;
                height: 38 / (theme.textTheme.headlineSmall?.fontSize ?? 38),
                // vertical-align: middle;
                textBaseline: TextBaseline.alphabetic,
                // leading-trim: NONE;
                textStyle: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
              ),
            ),
            AppSpacing.spacing24_Box,
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderMedium, width: 1),
                  ),
                ),
                AppSpacing.spacing16_Box,
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.contextName(context),
                      style: theme.textTheme.displayMedium!.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        );
      },
    );
  }
}
