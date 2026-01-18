part of '../profile.dart';

class TabletJourneyRewardsTab extends StatefulWidget {
  const TabletJourneyRewardsTab({super.key});

  @override
  State<TabletJourneyRewardsTab> createState() => _TabletJourneyRewardsTabState();
}

class _TabletJourneyRewardsTabState extends State<TabletJourneyRewardsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations locale = AppLocalizations.of(context);
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        final rewards = state.rewards;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Wrap(
                children: rewards.map((reward) {
                  return RewardCard(
                    reward: reward,
                    maxWith: constraints.maxWidth,
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }
}

class RewardCard extends StatelessWidget {
  final RewardItem reward;
  final double maxWith;
  const RewardCard({super.key, required this.reward, required this.maxWith});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
