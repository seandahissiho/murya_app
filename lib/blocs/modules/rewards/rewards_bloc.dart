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
    on<RewardsEvent>((event, emit) {
      emit(RewardsLoading.from(
        state,
        rewardsLoading: true,
      ));
    });
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
    emit(RewardsCatalogLoading.from(
      state,
      rewardsLoading: true,
      rewardsError: null,
    ));

    final cachedResult = await rewardsRepository.getRewardsCached(
      city: event.city,
      kind: event.kind,
      onlyAvailable: event.onlyAvailable,
      page: event.page,
      limit: event.limit,
    );
    final cachedCatalog = cachedResult.data;
    final hasCached = cachedCatalog != null && cachedCatalog.items.isNotEmpty;
    if (hasCached) {
      emit(RewardsCatalogLoaded.from(
        state,
        rewards: cachedCatalog.items,
        rewardsPage: cachedCatalog.page,
        rewardsLimit: cachedCatalog.limit,
        rewardsTotal: cachedCatalog.total,
        rewardsLoading: false,
        rewardsError: null,
      ));
    }

    final result = await rewardsRepository.getRewards(
      city: event.city,
      kind: event.kind,
      onlyAvailable: event.onlyAvailable,
      page: event.page,
      limit: event.limit,
    );

    if (result.isError) {
      emit(RewardsCatalogError.from(
        state,
        rewardsLoading: false,
        rewardsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }

    final catalog = result.data ?? RewardCatalog.empty();
    emit(RewardsCatalogLoaded.from(
      state,
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
    emit(RewardDetailsLoading.from(
      state,
      rewardDetailsLoading: true,
      rewardDetailsError: null,
    ));
    final cachedResult = await rewardsRepository.getRewardByIdCached(event.rewardId);
    final cachedReward = cachedResult.data;
    final hasCached = cachedReward != null && cachedReward.id.isNotEmpty;
    if (hasCached) {
      emit(RewardDetailsLoaded.from(
        state,
        rewardDetails: cachedReward,
        rewardDetailsLoading: false,
        rewardDetailsError: null,
      ));
    }
    final result = await rewardsRepository.getRewardById(event.rewardId);
    if (result.isError) {
      emit(RewardDetailsError.from(
        state,
        rewardDetailsLoading: false,
        rewardDetailsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(RewardDetailsLoaded.from(
      state,
      rewardDetails: result.data,
      rewardDetailsLoading: false,
      rewardDetailsError: null,
    ));
  }

  FutureOr<void> _onLoadRewardPurchases(LoadRewardPurchasesEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(RewardPurchasesLoading.from(
      state,
      purchasesLoading: true,
      purchasesError: null,
    ));

    final cachedResult = await rewardsRepository.getPurchasesCached(
      page: event.page,
      limit: event.limit,
    );
    final cachedPurchases = cachedResult.data;
    final hasCached = cachedPurchases != null && cachedPurchases.items.isNotEmpty;
    if (hasCached) {
      emit(RewardPurchasesLoaded.from(
        state,
        purchases: cachedPurchases.items,
        purchasesPage: cachedPurchases.page,
        purchasesLimit: cachedPurchases.limit,
        purchasesTotal: cachedPurchases.total,
        purchasesLoading: false,
        purchasesError: null,
      ));
    }

    final result = await rewardsRepository.getPurchases(
      page: event.page,
      limit: event.limit,
    );

    if (result.isError) {
      emit(RewardPurchasesError.from(
        state,
        purchasesLoading: false,
        purchasesError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }

    final purchases = result.data ?? RewardPurchaseList.empty();
    emit(RewardPurchasesLoaded.from(
      state,
      purchases: purchases.items,
      purchasesPage: purchases.page,
      purchasesLimit: purchases.limit,
      purchasesTotal: purchases.total,
      purchasesLoading: false,
      purchasesError: null,
    ));
  }

  FutureOr<void> _onLoadRewardPurchaseDetails(LoadRewardPurchaseDetailsEvent event, Emitter<RewardsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
    emit(RewardPurchaseDetailsLoading.from(
      state,
      purchaseDetailsLoading: true,
      purchaseDetailsError: null,
    ));
    final cachedResult = await rewardsRepository.getPurchaseByIdCached(event.purchaseId);
    final cachedPurchase = cachedResult.data;
    final hasCached = cachedPurchase != null && cachedPurchase.id.isNotEmpty;
    if (hasCached) {
      emit(RewardPurchaseDetailsLoaded.from(
        state,
        purchaseDetails: cachedPurchase,
        purchaseDetailsLoading: false,
        purchaseDetailsError: null,
      ));
    }
    final result = await rewardsRepository.getPurchaseById(event.purchaseId);
    if (result.isError) {
      emit(RewardPurchaseDetailsError.from(
        state,
        purchaseDetailsLoading: false,
        purchaseDetailsError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(RewardPurchaseDetailsLoaded.from(
      state,
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
    emit(RewardPurchaseSubmitting.from(
      state,
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
      emit(RewardPurchaseError.from(
        state,
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

    emit(RewardPurchaseSuccess.from(
      state,
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
    emit(RewardsWalletLoading.from(
      state,
      walletLoading: true,
      walletError: null,
    ));
    final cachedResult = await rewardsRepository.getWalletCached();
    if (cachedResult.data != null) {
      emit(RewardsWalletLoaded.from(
        state,
        wallet: cachedResult.data ?? Wallet.empty(),
        walletLoading: false,
        walletError: null,
      ));
    }
    final result = await rewardsRepository.getWallet();
    if (result.isError) {
      emit(RewardsWalletError.from(
        state,
        walletLoading: false,
        walletError: result.error ?? "Une erreur est survenue",
      ));
      return;
    }
    emit(RewardsWalletLoaded.from(
      state,
      wallet: result.data ?? Wallet.empty(),
      walletLoading: false,
      walletError: null,
    ));
  }

  FutureOr<void> _onClearPurchaseFeedback(ClearRewardPurchaseFeedbackEvent event, Emitter<RewardsState> emit) async {
    emit(RewardPurchaseFeedbackCleared.from(
      state,
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
