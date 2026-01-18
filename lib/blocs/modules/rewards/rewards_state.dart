part of 'rewards_bloc.dart';

@immutable
class RewardsState {
  final List<RewardItem> rewards;
  final bool rewardsLoading;
  final String? rewardsError;
  final int rewardsPage;
  final int rewardsLimit;
  final int rewardsTotal;

  final RewardItem? rewardDetails;
  final bool rewardDetailsLoading;
  final String? rewardDetailsError;

  final List<RewardPurchase> purchases;
  final bool purchasesLoading;
  final String? purchasesError;
  final int purchasesPage;
  final int purchasesLimit;
  final int purchasesTotal;

  final RewardPurchase? purchaseDetails;
  final bool purchaseDetailsLoading;
  final String? purchaseDetailsError;

  final bool purchaseSubmitting;
  final String? purchaseError;
  final RewardPurchase? lastPurchase;

  final Wallet wallet;
  final bool walletLoading;
  final String? walletError;

  const RewardsState({
    required this.rewards,
    required this.rewardsLoading,
    required this.rewardsError,
    required this.rewardsPage,
    required this.rewardsLimit,
    required this.rewardsTotal,
    required this.rewardDetails,
    required this.rewardDetailsLoading,
    required this.rewardDetailsError,
    required this.purchases,
    required this.purchasesLoading,
    required this.purchasesError,
    required this.purchasesPage,
    required this.purchasesLimit,
    required this.purchasesTotal,
    required this.purchaseDetails,
    required this.purchaseDetailsLoading,
    required this.purchaseDetailsError,
    required this.purchaseSubmitting,
    required this.purchaseError,
    required this.lastPurchase,
    required this.wallet,
    required this.walletLoading,
    required this.walletError,
  });

  static const _unset = Object();

  factory RewardsState.initial() => RewardsState(
        rewards: const [],
        rewardsLoading: false,
        rewardsError: null,
        rewardsPage: 1,
        rewardsLimit: 20,
        rewardsTotal: 0,
        rewardDetails: null,
        rewardDetailsLoading: false,
        rewardDetailsError: null,
        purchases: const [],
        purchasesLoading: false,
        purchasesError: null,
        purchasesPage: 1,
        purchasesLimit: 20,
        purchasesTotal: 0,
        purchaseDetails: null,
        purchaseDetailsLoading: false,
        purchaseDetailsError: null,
        purchaseSubmitting: false,
        purchaseError: null,
        lastPurchase: null,
        wallet: Wallet.empty(),
        walletLoading: false,
        walletError: null,
      );

  RewardsState copyWith({
    List<RewardItem>? rewards,
    bool? rewardsLoading,
    Object? rewardsError = _unset,
    int? rewardsPage,
    int? rewardsLimit,
    int? rewardsTotal,
    Object? rewardDetails = _unset,
    bool? rewardDetailsLoading,
    Object? rewardDetailsError = _unset,
    List<RewardPurchase>? purchases,
    bool? purchasesLoading,
    Object? purchasesError = _unset,
    int? purchasesPage,
    int? purchasesLimit,
    int? purchasesTotal,
    Object? purchaseDetails = _unset,
    bool? purchaseDetailsLoading,
    Object? purchaseDetailsError = _unset,
    bool? purchaseSubmitting,
    Object? purchaseError = _unset,
    Object? lastPurchase = _unset,
    Wallet? wallet,
    bool? walletLoading,
    Object? walletError = _unset,
  }) {
    return RewardsState(
      rewards: rewards ?? this.rewards,
      rewardsLoading: rewardsLoading ?? this.rewardsLoading,
      rewardsError: rewardsError == _unset ? this.rewardsError : rewardsError as String?,
      rewardsPage: rewardsPage ?? this.rewardsPage,
      rewardsLimit: rewardsLimit ?? this.rewardsLimit,
      rewardsTotal: rewardsTotal ?? this.rewardsTotal,
      rewardDetails: rewardDetails == _unset ? this.rewardDetails : rewardDetails as RewardItem?,
      rewardDetailsLoading: rewardDetailsLoading ?? this.rewardDetailsLoading,
      rewardDetailsError:
          rewardDetailsError == _unset ? this.rewardDetailsError : rewardDetailsError as String?,
      purchases: purchases ?? this.purchases,
      purchasesLoading: purchasesLoading ?? this.purchasesLoading,
      purchasesError: purchasesError == _unset ? this.purchasesError : purchasesError as String?,
      purchasesPage: purchasesPage ?? this.purchasesPage,
      purchasesLimit: purchasesLimit ?? this.purchasesLimit,
      purchasesTotal: purchasesTotal ?? this.purchasesTotal,
      purchaseDetails: purchaseDetails == _unset ? this.purchaseDetails : purchaseDetails as RewardPurchase?,
      purchaseDetailsLoading: purchaseDetailsLoading ?? this.purchaseDetailsLoading,
      purchaseDetailsError:
          purchaseDetailsError == _unset ? this.purchaseDetailsError : purchaseDetailsError as String?,
      purchaseSubmitting: purchaseSubmitting ?? this.purchaseSubmitting,
      purchaseError: purchaseError == _unset ? this.purchaseError : purchaseError as String?,
      lastPurchase: lastPurchase == _unset ? this.lastPurchase : lastPurchase as RewardPurchase?,
      wallet: wallet ?? this.wallet,
      walletLoading: walletLoading ?? this.walletLoading,
      walletError: walletError == _unset ? this.walletError : walletError as String?,
    );
  }
}
