import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/models/reward.dart';
import 'package:murya/models/reward_catalog.dart';
import 'package:murya/models/reward_purchase.dart';
import 'package:murya/repositories/rewards.repository.dart';
import 'package:uuid/uuid.dart';

part 'rewards_event.dart';
part 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  final BuildContext context;
  late final RewardsRepository rewardsRepository;
  late final AuthenticationBloc authBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;
  final Uuid _uuid = const Uuid();

  RewardsBloc({required this.context}) : super(RewardsState.initial()) {
    on<LoadRewardsEvent>(_onLoadRewards);
    on<LoadRewardDetailsEvent>(_onLoadRewardDetails);
    on<LoadRewardPurchasesEvent>(_onLoadRewardPurchases);
    on<LoadRewardPurchaseDetailsEvent>(_onLoadRewardPurchaseDetails);
    on<PurchaseRewardEvent>(_onPurchaseReward);
    on<LoadWalletEvent>(_onLoadWallet);
    on<ClearRewardPurchaseFeedbackEvent>(_onClearPurchaseFeedback);

    rewardsRepository = RepositoryProvider.of<RewardsRepository>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);

    _authSubscription = authBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(const LoadRewardsEvent());
        add(const LoadRewardPurchasesEvent());
        add(const LoadWalletEvent());
      }
    });
  }

  FutureOr<void> _onLoadRewards(LoadRewardsEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      rewardsLoading: true,
      rewardsError: null,
    ));

    final result = await rewardsRepository.getRewards(
      city: event.city,
      kind: event.kind,
      onlyAvailable: event.onlyAvailable,
      page: event.page,
      limit: event.limit,
    );

    if (result.isError) {
      emit(state.copyWith(
        rewardsLoading: false,
        rewardsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }

    final catalog = result.data ?? RewardCatalog.empty();
    emit(state.copyWith(
      rewards: catalog.items,
      rewardsPage: catalog.page,
      rewardsLimit: catalog.limit,
      rewardsTotal: catalog.total,
      rewardsLoading: false,
      rewardsError: null,
    ));
  }

  FutureOr<void> _onLoadRewardDetails(LoadRewardDetailsEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      rewardDetailsLoading: true,
      rewardDetailsError: null,
    ));
    final result = await rewardsRepository.getRewardById(event.rewardId);
    if (result.isError) {
      emit(state.copyWith(
        rewardDetailsLoading: false,
        rewardDetailsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(state.copyWith(
      rewardDetails: result.data,
      rewardDetailsLoading: false,
      rewardDetailsError: null,
    ));
  }

  FutureOr<void> _onLoadRewardPurchases(LoadRewardPurchasesEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      purchasesLoading: true,
      purchasesError: null,
    ));

    final result = await rewardsRepository.getPurchases(
      page: event.page,
      limit: event.limit,
    );

    if (result.isError) {
      emit(state.copyWith(
        purchasesLoading: false,
        purchasesError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }

    final purchases = result.data ?? RewardPurchaseList.empty();
    emit(state.copyWith(
      purchases: purchases.items,
      purchasesPage: purchases.page,
      purchasesLimit: purchases.limit,
      purchasesTotal: purchases.total,
      purchasesLoading: false,
      purchasesError: null,
    ));
  }

  FutureOr<void> _onLoadRewardPurchaseDetails(
      LoadRewardPurchaseDetailsEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      purchaseDetailsLoading: true,
      purchaseDetailsError: null,
    ));
    final result = await rewardsRepository.getPurchaseById(event.purchaseId);
    if (result.isError) {
      emit(state.copyWith(
        purchaseDetailsLoading: false,
        purchaseDetailsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(state.copyWith(
      purchaseDetails: result.data,
      purchaseDetailsLoading: false,
      purchaseDetailsError: null,
    ));
  }

  FutureOr<void> _onPurchaseReward(PurchaseRewardEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    if (state.purchaseSubmitting) {
      return;
    }
    emit(state.copyWith(
      purchaseSubmitting: true,
      purchaseError: null,
    ));

    final idempotencyKey = event.idempotencyKey ?? _uuid.v4();
    final result = await rewardsRepository.purchaseReward(
      rewardId: event.rewardId,
      idempotencyKey: idempotencyKey,
      quantity: event.quantity,
    );

    if (result.isError) {
      emit(state.copyWith(
        purchaseSubmitting: false,
        purchaseError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }

    final payload = result.data;
    final updatedPurchases = [
      if (payload != null) payload.purchase,
      ...state.purchases,
    ];

    emit(state.copyWith(
      purchaseSubmitting: false,
      purchaseError: null,
      lastPurchase: payload?.purchase,
      purchases: updatedPurchases,
      wallet: payload?.wallet ?? state.wallet,
    ));

    add(const LoadRewardsEvent());
  }

  FutureOr<void> _onLoadWallet(LoadWalletEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(state.copyWith(
      walletLoading: true,
      walletError: null,
    ));
    final result = await rewardsRepository.getWallet();
    if (result.isError) {
      emit(state.copyWith(
        walletLoading: false,
        walletError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(state.copyWith(
      wallet: result.data ?? Wallet.empty(),
      walletLoading: false,
      walletError: null,
    ));
  }

  FutureOr<void> _onClearPurchaseFeedback(
      ClearRewardPurchaseFeedbackEvent event, Emitter<RewardsState> emit) async {
    emit(state.copyWith(
      purchaseError: null,
      lastPurchase: null,
    ));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
