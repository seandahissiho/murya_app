part of 'rewards_bloc.dart';

@immutable
sealed class RewardsEvent {
  const RewardsEvent();
}

final class LoadRewardsEvent extends RewardsEvent {
  final String? city;
  final String? kind;
  final bool? onlyAvailable;
  final int page;
  final int limit;

  const LoadRewardsEvent({
    this.city,
    this.kind,
    this.onlyAvailable = true,
    this.page = 1,
    this.limit = 20,
  });
}

final class LoadRewardDetailsEvent extends RewardsEvent {
  final String rewardId;

  const LoadRewardDetailsEvent({required this.rewardId});
}

final class LoadRewardPurchasesEvent extends RewardsEvent {
  final int page;
  final int limit;

  const LoadRewardPurchasesEvent({
    this.page = 1,
    this.limit = 20,
  });
}

final class LoadRewardPurchaseDetailsEvent extends RewardsEvent {
  final String purchaseId;

  const LoadRewardPurchaseDetailsEvent({required this.purchaseId});
}

final class PurchaseRewardEvent extends RewardsEvent {
  final String rewardId;
  final int quantity;
  final String? idempotencyKey;

  const PurchaseRewardEvent({
    required this.rewardId,
    this.quantity = 1,
    this.idempotencyKey,
  });
}

final class LoadWalletEvent extends RewardsEvent {
  const LoadWalletEvent();
}

final class ClearRewardPurchaseFeedbackEvent extends RewardsEvent {
  const ClearRewardPurchaseFeedbackEvent();
}
