part of '../profile.dart';

class TabletJourneyRewardsTab extends StatefulWidget {
  const TabletJourneyRewardsTab({super.key});

  @override
  State<TabletJourneyRewardsTab> createState() => _TabletJourneyRewardsTabState();
}

class _TabletJourneyRewardsTabState extends State<TabletJourneyRewardsTab> {
  bool _didLoad = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_didLoad) return;
      _didLoad = true;
      final rewardsBloc = context.read<RewardsBloc>();
      rewardsBloc.add(const LoadRewardsEvent());
      rewardsBloc.add(const LoadRewardPurchasesEvent());
      rewardsBloc.add(const LoadWalletEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<RewardsBloc, RewardsState>(
      builder: (context, state) {
        final demoRewards = <RewardItem>[
          const RewardItem(
            id: "reward_le_dietrich",
            title: "Le Dietrich",
            kind: RewardKind.cinema,
            city: "Poitiers",
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/15-movies-set-in-turkey_5cef7069-aa9a-4cd1-adc0-fcf4d19203bf.webp?alt=media&token=cb74c199-be90-40f6-b0ca-fae56cf55fd7",
            remainingPlaces: 5,
            costDiamonds: 200,
            address: RewardAddress(
              line1: "34 Boulevard Chasseigne",
              postalCode: "86000",
              city: "Poitiers",
              googleMapsUrl:
                  "https://www.google.com/maps/search/?api=1&query=34%20Boulevard%20Chasseigne%2C%2086000%20Poitiers%2C%20France",
            ),
          ),
          const RewardItem(
            id: "reward_confort_moderne",
            title: "Le Confort Moderne",
            kind: RewardKind.concertHall,
            city: "Poitiers",
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/tap-poitiers.webp?alt=media&token=adeabe1c-2064-4642-9c82-25eb45f8388f",
            remainingPlaces: 5,
            costDiamonds: 350,
            address: RewardAddress(
              line1: "185 Rue du Faubourg du Pont-Neuf",
              postalCode: "86000",
              city: "Poitiers",
              googleMapsUrl:
                  "https://www.google.com/maps/search/?api=1&query=185%20Rue%20du%20Faubourg%20du%20Pont-Neuf%2C%2086000%20Poitiers%2C%20France",
            ),
          ),
          const RewardItem(
            id: "reward_theatre_auditorium",
            title: "Théâtre Auditorium",
            kind: RewardKind.theatre,
            city: "Poitiers",
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/5a35cb1c459a45014e8b45b5.webp?alt=media&token=5c3fb9c4-9fb1-4a9c-8e7c-9a7786d195f5",
            remainingPlaces: 5,
            costDiamonds: 400,
            address: RewardAddress(
              line1: "6 Rue de la Marne",
              postalCode: "86000",
              city: "Poitiers",
              googleMapsUrl:
                  "https://www.google.com/maps/search/?api=1&query=6%20Rue%20de%20la%20Marne%2C%2086000%20Poitiers%2C%20France",
            ),
          ),
          const RewardItem(
            id: "reward_pb86",
            title: "PB86",
            kind: RewardKind.sportsMatch,
            city: "Poitiers",
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/arena-futuroscope-poitiers-basket.jpg?alt=media&token=74c5e006-21d5-4407-9405-d88433da02b6",
            remainingPlaces: 5,
            costDiamonds: 250,
            address: RewardAddress(
              line1: "Arena Futuroscope, Avenue du Futuroscope",
              postalCode: "86360",
              city: "Chasseneuil-du-Poitou",
              googleMapsUrl:
                  "https://www.google.com/maps/search/?api=1&query=Arena%20Futuroscope%2C%20Avenue%20du%20Futuroscope%2C%2086360%20Chasseneuil-du-Poitou%2C%20France",
            ),
          ),
          const RewardItem(
            id: "reward_futuroscope",
            title: "Futuroscope",
            kind: RewardKind.themePark,
            city: "Poitiers",
            imageUrl:
                "https://firebasestorage.googleapis.com/v0/b/murya-c861b.firebasestorage.app/o/9485c939acd9496783a80d3473b0cad8.avif?alt=media&token=7295f9ba-0829-44c8-a07c-4bc74900d578",
            remainingPlaces: 5,
            costDiamonds: 500,
            address: RewardAddress(
              line1: "Avenue René Monory",
              postalCode: "86360",
              city: "Chasseneuil-du-Poitou",
              googleMapsUrl:
                  "https://www.google.com/maps/search/?api=1&query=Avenue%20Ren%C3%A9%20Monory%2C%2086360%20Chasseneuil-du-Poitou%2C%20France",
            ),
          ),
        ];
        final rewards = demoRewards; // state.rewards;
        final purchases = state.purchases;
        return LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              alignment: WrapAlignment.start,
              spacing: AppSpacing.textFieldMargin,
              runSpacing: AppSpacing.textFieldMargin,
              children: rewards.map((reward) {
                return Container(
                  height: 325,
                  width: (constraints.maxWidth / 4) - 3 * AppSpacing.textFieldMargin,
                  constraints: const BoxConstraints(
                    maxWidth: 313,
                    minWidth: 250,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.small,
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.small,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Image.network(
                                reward.imageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.borderLight,
                                    height: 150,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  height: 24,
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    borderRadius: AppRadius.tinyTiny,
                                    // rgba(255, 214, 0, 1)
                                    color: Color.fromRGBO(255, 214, 0, 0.85),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AppIcons.fireIconPath,
                                        height: 16,
                                        width: 16,
                                      ),
                                      AppSpacing.elementMarginBox,
                                      Text(
                                        "${reward.remainingPlaces} places restantes",
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AppSpacing.textFieldMarginBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.textFieldMargin),
                          child: Text(
                            reward.title,
                            style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.textFieldMargin),
                          child: Text(
                            "${reward.kind.labelFr} • ${reward.city}",
                            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.textFieldMargin),
                          child: AppXButton(
                            shrinkWrap: false,
                            text: "Débloquer",
                            disabled: !reward.canBuy ||
                                reward.remainingPlaces <= 0 ||
                                reward.costDiamonds > state.wallet.diamonds,
                            onPressed: () async {
                              return await contentNotAvailablePopup(context);
                            },
                            isLoading: state is RewardsLoading,
                          ),
                        ),
                        AppSpacing.textFieldMarginBox,
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}
