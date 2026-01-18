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
        final rewards = state.rewards;
        final purchases = state.purchases;
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RewardsHeader(walletDiamonds: state.wallet.diamonds),
                  if (state.rewardsError != null) ...[
                    AppSpacing.groupMarginBox,
                    Text(
                      state.rewardsError!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppStatusColors.serious),
                    ),
                  ],
                  AppSpacing.groupMarginBox,
                  if (state.rewardsLoading && rewards.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    Wrap(
                      spacing: AppSpacing.groupMargin,
                      runSpacing: AppSpacing.groupMargin,
                      children: rewards.map((reward) {
                        return RewardCard(
                          reward: reward,
                          maxWith: constraints.maxWidth,
                          walletDiamonds: state.wallet.diamonds,
                          isSubmitting: state.purchaseSubmitting,
                        );
                      }).toList(),
                    ),
                  AppSpacing.sectionMarginBox,
                  Text(
                    "Historique des achats",
                    style: GoogleFonts.anton(
                      fontSize: theme.textTheme.headlineSmall?.fontSize,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (state.purchasesError != null) ...[
                    AppSpacing.groupMarginBox,
                    Text(
                      state.purchasesError!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppStatusColors.serious),
                    ),
                  ],
                  if (state.purchaseError != null) ...[
                    AppSpacing.groupMarginBox,
                    Text(
                      _purchaseErrorLabel(state.purchaseError!),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppStatusColors.serious),
                    ),
                  ],
                  AppSpacing.groupMarginBox,
                  if (state.purchasesLoading && purchases.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (purchases.isEmpty)
                    Text(
                      "Aucun achat pour le moment.",
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    )
                  else
                    Column(
                      children: purchases.map((purchase) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.groupMargin),
                          child: RewardPurchaseCard(purchase: purchase),
                        );
                      }).toList(),
                    ),
                ],
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
  final int walletDiamonds;
  final bool isSubmitting;

  const RewardCard({
    super.key,
    required this.reward,
    required this.maxWith,
    required this.walletDiamonds,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBuy = reward.canBuy && reward.remainingPlaces > 0 && !isSubmitting;
    final double width = math.min(360, maxWith);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.smallRadius)),
              child: Image.network(
                reward.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.borderLight,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: AppColors.textSecondary),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                AppSpacing.tinyTinyMarginBox,
                Text(
                  "${reward.kind.labelFr} • ${reward.city}",
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.tinyTinyMarginBox,
                Text(
                  reward.address.fullAddress,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.groupMarginBox,
                Text(
                  "${reward.remainingPlaces} places restantes",
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                AppSpacing.tinyMarginBox,
                Row(
                  children: [
                    ScoreWidget(
                      value: reward.costDiamonds,
                      compact: true,
                      textColor: AppColors.textPrimary,
                      iconColor: AppColors.primaryFocus,
                    ),
                    AppSpacing.tinyMarginBox,
                    Text(
                      "Diamants",
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                AppSpacing.groupMarginBox,
                if (reward.address.googleMapsUrl.isNotEmpty)
                  InkWell(
                    onTap: () => openUrl(reward.address.googleMapsUrl),
                    child: Text(
                      "Ouvrir dans Google Maps",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryFocus,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                if (!canBuy) ...[
                  AppSpacing.groupMarginBox,
                  Text(
                    _canBuyReasonLabel(reward),
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppStatusColors.serious),
                  ),
                ],
                AppSpacing.groupMarginBox,
                AppXButton(
                  text: "Débloquer",
                  isLoading: isSubmitting,
                  disabled: !canBuy,
                  onPressed: () async {
                    if (!canBuy) return;
                    final remaining = walletDiamonds - reward.costDiamonds;
                    final result = await displayPopUp(
                      context: context,
                      okText: "Débloquer",
                      cancelText: "Annuler",
                      okEnabled: canBuy,
                      contents: [
                        Text(
                          "Confirmer l'achat",
                          style: theme.textTheme.titleLarge,
                        ),
                        AppSpacing.groupMarginBox,
                        Text(
                          reward.title,
                          style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                        ),
                        AppSpacing.groupMarginBox,
                        _costRow("Coût", reward.costDiamonds),
                        AppSpacing.tinyMarginBox,
                        _costRow("Solde actuel", walletDiamonds),
                        AppSpacing.tinyMarginBox,
                        _costRow("Solde après achat", remaining),
                        AppSpacing.groupMarginBox,
                      ],
                    );
                    if (result == true && context.mounted) {
                      context.read<RewardsBloc>().add(PurchaseRewardEvent(rewardId: reward.id));
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RewardPurchaseCard extends StatelessWidget {
  final RewardPurchase purchase;

  const RewardPurchaseCard({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = purchase.isFulfilling ? "En cours de préparation" : purchase.status;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purchase.reward.title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.tinyTinyMarginBox,
          Text(
            statusLabel,
            style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          if (purchase.isReady && (purchase.voucherCode != null || purchase.voucherLink != null)) ...[
            AppSpacing.groupMarginBox,
            if (purchase.voucherCode != null && purchase.voucherCode!.isNotEmpty)
              Text(
                "Code: ${purchase.voucherCode}",
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            if (purchase.voucherLink != null && purchase.voucherLink!.isNotEmpty) ...[
              AppSpacing.tinyMarginBox,
              InkWell(
                onTap: () => openUrl(purchase.voucherLink),
                child: Text(
                  "Ouvrir le voucher",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryFocus,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RewardsHeader extends StatelessWidget {
  final int walletDiamonds;

  const _RewardsHeader({required this.walletDiamonds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Shop Récompenses",
          style: GoogleFonts.anton(
            fontSize: theme.textTheme.headlineMedium?.fontSize,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            Text(
              "Diamants:",
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            AppSpacing.tinyMarginBox,
            ScoreWidget(
              value: walletDiamonds,
              compact: true,
              textColor: AppColors.textPrimary,
              iconColor: AppColors.primaryFocus,
            ),
          ],
        ),
      ],
    );
  }
}

Widget _costRow(String label, int cost) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      ScoreWidget(
        value: cost,
        compact: true,
        textColor: AppColors.textPrimary,
        iconColor: AppColors.primaryFocus,
      ),
    ],
  );
}

String _canBuyReasonLabel(RewardItem reward) {
  if (reward.remainingPlaces <= 0) {
    return "Stock épuisé";
  }
  switch (reward.canBuyReason) {
    case "NOT_ENOUGH_DIAMONDS":
      return "Pas assez de diamants";
    case "OUT_OF_STOCK":
      return "Stock épuisé";
    case "REWARD_NOT_ACTIVE":
      return "Récompense inactive";
    default:
      return "Indisponible pour le moment";
  }
}

String _purchaseErrorLabel(String error) {
  switch (error) {
    case "NOT_ENOUGH_DIAMONDS":
      return "Pas assez de diamants pour cet achat.";
    case "OUT_OF_STOCK":
      return "Stock épuisé pour cette récompense.";
    case "REWARD_NOT_ACTIVE":
      return "Récompense inactive.";
    case "IDEMPOTENCY_REPLAY":
      return "Achat déjà pris en compte.";
    default:
      return error;
  }
}
