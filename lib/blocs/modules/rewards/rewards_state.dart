part of 'rewards_bloc.dart';

@immutable
sealed class RewardsState {
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

  RewardsState.fromFields(_RewardsStateFields fields)
      : rewards = fields.rewards,
        rewardsLoading = fields.rewardsLoading,
        rewardsError = fields.rewardsError,
        rewardsPage = fields.rewardsPage,
        rewardsLimit = fields.rewardsLimit,
        rewardsTotal = fields.rewardsTotal,
        rewardDetails = fields.rewardDetails,
        rewardDetailsLoading = fields.rewardDetailsLoading,
        rewardDetailsError = fields.rewardDetailsError,
        purchases = fields.purchases,
        purchasesLoading = fields.purchasesLoading,
        purchasesError = fields.purchasesError,
        purchasesPage = fields.purchasesPage,
        purchasesLimit = fields.purchasesLimit,
        purchasesTotal = fields.purchasesTotal,
        purchaseDetails = fields.purchaseDetails,
        purchaseDetailsLoading = fields.purchaseDetailsLoading,
        purchaseDetailsError = fields.purchaseDetailsError,
        purchaseSubmitting = fields.purchaseSubmitting,
        purchaseError = fields.purchaseError,
        lastPurchase = fields.lastPurchase,
        wallet = fields.wallet,
        walletLoading = fields.walletLoading,
        walletError = fields.walletError;

  static const _unset = Object();

  factory RewardsState.initial() => RewardsInitial._(_RewardsStateFields.initial());

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
    return RewardsInitial._(
      _RewardsStateFields(
        rewards: rewards ?? this.rewards,
        rewardsLoading: rewardsLoading ?? this.rewardsLoading,
        rewardsError: rewardsError == _unset ? this.rewardsError : rewardsError as String?,
        rewardsPage: rewardsPage ?? this.rewardsPage,
        rewardsLimit: rewardsLimit ?? this.rewardsLimit,
        rewardsTotal: rewardsTotal ?? this.rewardsTotal,
        rewardDetails: rewardDetails == _unset ? this.rewardDetails : rewardDetails as RewardItem?,
        rewardDetailsLoading: rewardDetailsLoading ?? this.rewardDetailsLoading,
        rewardDetailsError: rewardDetailsError == _unset ? this.rewardDetailsError : rewardDetailsError as String?,
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
      ),
    );
  }
}

class RewardsLoading extends RewardsState {
  RewardsLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsLoading.from(RewardsState state, {bool? rewardsLoading}) {
    return RewardsLoading._(
      _updatedFields(state, rewardsLoading: rewardsLoading),
    );
  }
}

class _RewardsStateFields {
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

  const _RewardsStateFields({
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

  factory _RewardsStateFields.initial() => _RewardsStateFields(
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

  factory _RewardsStateFields.fromState(RewardsState state) => _RewardsStateFields(
        rewards: state.rewards,
        rewardsLoading: state.rewardsLoading,
        rewardsError: state.rewardsError,
        rewardsPage: state.rewardsPage,
        rewardsLimit: state.rewardsLimit,
        rewardsTotal: state.rewardsTotal,
        rewardDetails: state.rewardDetails,
        rewardDetailsLoading: state.rewardDetailsLoading,
        rewardDetailsError: state.rewardDetailsError,
        purchases: state.purchases,
        purchasesLoading: state.purchasesLoading,
        purchasesError: state.purchasesError,
        purchasesPage: state.purchasesPage,
        purchasesLimit: state.purchasesLimit,
        purchasesTotal: state.purchasesTotal,
        purchaseDetails: state.purchaseDetails,
        purchaseDetailsLoading: state.purchaseDetailsLoading,
        purchaseDetailsError: state.purchaseDetailsError,
        purchaseSubmitting: state.purchaseSubmitting,
        purchaseError: state.purchaseError,
        lastPurchase: state.lastPurchase,
        wallet: state.wallet,
        walletLoading: state.walletLoading,
        walletError: state.walletError,
      );
}

_RewardsStateFields _updatedFields(
  RewardsState state, {
  List<RewardItem>? rewards,
  bool? rewardsLoading,
  Object? rewardsError = RewardsState._unset,
  int? rewardsPage,
  int? rewardsLimit,
  int? rewardsTotal,
  Object? rewardDetails = RewardsState._unset,
  bool? rewardDetailsLoading,
  Object? rewardDetailsError = RewardsState._unset,
  List<RewardPurchase>? purchases,
  bool? purchasesLoading,
  Object? purchasesError = RewardsState._unset,
  int? purchasesPage,
  int? purchasesLimit,
  int? purchasesTotal,
  Object? purchaseDetails = RewardsState._unset,
  bool? purchaseDetailsLoading,
  Object? purchaseDetailsError = RewardsState._unset,
  bool? purchaseSubmitting,
  Object? purchaseError = RewardsState._unset,
  Object? lastPurchase = RewardsState._unset,
  Wallet? wallet,
  bool? walletLoading,
  Object? walletError = RewardsState._unset,
}) {
  final updated = state.copyWith(
    rewards: rewards,
    rewardsLoading: rewardsLoading,
    rewardsError: rewardsError,
    rewardsPage: rewardsPage,
    rewardsLimit: rewardsLimit,
    rewardsTotal: rewardsTotal,
    rewardDetails: rewardDetails,
    rewardDetailsLoading: rewardDetailsLoading,
    rewardDetailsError: rewardDetailsError,
    purchases: purchases,
    purchasesLoading: purchasesLoading,
    purchasesError: purchasesError,
    purchasesPage: purchasesPage,
    purchasesLimit: purchasesLimit,
    purchasesTotal: purchasesTotal,
    purchaseDetails: purchaseDetails,
    purchaseDetailsLoading: purchaseDetailsLoading,
    purchaseDetailsError: purchaseDetailsError,
    purchaseSubmitting: purchaseSubmitting,
    purchaseError: purchaseError,
    lastPurchase: lastPurchase,
    wallet: wallet,
    walletLoading: walletLoading,
    walletError: walletError,
  );
  return _RewardsStateFields.fromState(updated);
}

class RewardsInitial extends RewardsState {
  RewardsInitial._(_RewardsStateFields fields) : super.fromFields(fields);
}

class RewardsCatalogLoading extends RewardsState {
  RewardsCatalogLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsCatalogLoading.from(
    RewardsState state, {
    bool? rewardsLoading,
    Object? rewardsError = RewardsState._unset,
  }) {
    return RewardsCatalogLoading._(
      _updatedFields(state, rewardsLoading: rewardsLoading, rewardsError: rewardsError),
    );
  }
}

class RewardsCatalogLoaded extends RewardsState {
  RewardsCatalogLoaded._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsCatalogLoaded.from(
    RewardsState state, {
    List<RewardItem>? rewards,
    int? rewardsPage,
    int? rewardsLimit,
    int? rewardsTotal,
    bool? rewardsLoading,
    Object? rewardsError = RewardsState._unset,
  }) {
    return RewardsCatalogLoaded._(
      _updatedFields(
        state,
        rewards: rewards,
        rewardsPage: rewardsPage,
        rewardsLimit: rewardsLimit,
        rewardsTotal: rewardsTotal,
        rewardsLoading: rewardsLoading,
        rewardsError: rewardsError,
      ),
    );
  }
}

class RewardsCatalogError extends RewardsState {
  RewardsCatalogError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsCatalogError.from(
    RewardsState state, {
    bool? rewardsLoading,
    Object? rewardsError = RewardsState._unset,
  }) {
    return RewardsCatalogError._(
      _updatedFields(state, rewardsLoading: rewardsLoading, rewardsError: rewardsError),
    );
  }
}

class RewardDetailsLoading extends RewardsState {
  RewardDetailsLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardDetailsLoading.from(
    RewardsState state, {
    bool? rewardDetailsLoading,
    Object? rewardDetailsError = RewardsState._unset,
  }) {
    return RewardDetailsLoading._(
      _updatedFields(state, rewardDetailsLoading: rewardDetailsLoading, rewardDetailsError: rewardDetailsError),
    );
  }
}

class RewardDetailsLoaded extends RewardsState {
  RewardDetailsLoaded._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardDetailsLoaded.from(
    RewardsState state, {
    Object? rewardDetails = RewardsState._unset,
    bool? rewardDetailsLoading,
    Object? rewardDetailsError = RewardsState._unset,
  }) {
    return RewardDetailsLoaded._(
      _updatedFields(
        state,
        rewardDetails: rewardDetails,
        rewardDetailsLoading: rewardDetailsLoading,
        rewardDetailsError: rewardDetailsError,
      ),
    );
  }
}

class RewardDetailsError extends RewardsState {
  RewardDetailsError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardDetailsError.from(
    RewardsState state, {
    bool? rewardDetailsLoading,
    Object? rewardDetailsError = RewardsState._unset,
  }) {
    return RewardDetailsError._(
      _updatedFields(state, rewardDetailsLoading: rewardDetailsLoading, rewardDetailsError: rewardDetailsError),
    );
  }
}

class RewardPurchasesLoading extends RewardsState {
  RewardPurchasesLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchasesLoading.from(
    RewardsState state, {
    bool? purchasesLoading,
    Object? purchasesError = RewardsState._unset,
  }) {
    return RewardPurchasesLoading._(
      _updatedFields(state, purchasesLoading: purchasesLoading, purchasesError: purchasesError),
    );
  }
}

class RewardPurchasesLoaded extends RewardsState {
  RewardPurchasesLoaded._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchasesLoaded.from(
    RewardsState state, {
    List<RewardPurchase>? purchases,
    int? purchasesPage,
    int? purchasesLimit,
    int? purchasesTotal,
    bool? purchasesLoading,
    Object? purchasesError = RewardsState._unset,
  }) {
    return RewardPurchasesLoaded._(
      _updatedFields(
        state,
        purchases: purchases,
        purchasesPage: purchasesPage,
        purchasesLimit: purchasesLimit,
        purchasesTotal: purchasesTotal,
        purchasesLoading: purchasesLoading,
        purchasesError: purchasesError,
      ),
    );
  }
}

class RewardPurchasesError extends RewardsState {
  RewardPurchasesError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchasesError.from(
    RewardsState state, {
    bool? purchasesLoading,
    Object? purchasesError = RewardsState._unset,
  }) {
    return RewardPurchasesError._(
      _updatedFields(state, purchasesLoading: purchasesLoading, purchasesError: purchasesError),
    );
  }
}

class RewardPurchaseDetailsLoading extends RewardsState {
  RewardPurchaseDetailsLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseDetailsLoading.from(
    RewardsState state, {
    bool? purchaseDetailsLoading,
    Object? purchaseDetailsError = RewardsState._unset,
  }) {
    return RewardPurchaseDetailsLoading._(
      _updatedFields(
        state,
        purchaseDetailsLoading: purchaseDetailsLoading,
        purchaseDetailsError: purchaseDetailsError,
      ),
    );
  }
}

class RewardPurchaseDetailsLoaded extends RewardsState {
  RewardPurchaseDetailsLoaded._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseDetailsLoaded.from(
    RewardsState state, {
    Object? purchaseDetails = RewardsState._unset,
    bool? purchaseDetailsLoading,
    Object? purchaseDetailsError = RewardsState._unset,
  }) {
    return RewardPurchaseDetailsLoaded._(
      _updatedFields(
        state,
        purchaseDetails: purchaseDetails,
        purchaseDetailsLoading: purchaseDetailsLoading,
        purchaseDetailsError: purchaseDetailsError,
      ),
    );
  }
}

class RewardPurchaseDetailsError extends RewardsState {
  RewardPurchaseDetailsError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseDetailsError.from(
    RewardsState state, {
    bool? purchaseDetailsLoading,
    Object? purchaseDetailsError = RewardsState._unset,
  }) {
    return RewardPurchaseDetailsError._(
      _updatedFields(
        state,
        purchaseDetailsLoading: purchaseDetailsLoading,
        purchaseDetailsError: purchaseDetailsError,
      ),
    );
  }
}

class RewardPurchaseSubmitting extends RewardsState {
  RewardPurchaseSubmitting._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseSubmitting.from(
    RewardsState state, {
    bool? purchaseSubmitting,
    Object? purchaseError = RewardsState._unset,
  }) {
    return RewardPurchaseSubmitting._(
      _updatedFields(
        state,
        purchaseSubmitting: purchaseSubmitting,
        purchaseError: purchaseError,
      ),
    );
  }
}

class RewardPurchaseSuccess extends RewardsState {
  RewardPurchaseSuccess._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseSuccess.from(
    RewardsState state, {
    List<RewardPurchase>? purchases,
    Object? lastPurchase = RewardsState._unset,
    Wallet? wallet,
    bool? purchaseSubmitting,
    Object? purchaseError = RewardsState._unset,
  }) {
    return RewardPurchaseSuccess._(
      _updatedFields(
        state,
        purchases: purchases,
        lastPurchase: lastPurchase,
        wallet: wallet,
        purchaseSubmitting: purchaseSubmitting,
        purchaseError: purchaseError,
      ),
    );
  }
}

class RewardPurchaseError extends RewardsState {
  RewardPurchaseError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseError.from(
    RewardsState state, {
    bool? purchaseSubmitting,
    Object? purchaseError = RewardsState._unset,
  }) {
    return RewardPurchaseError._(
      _updatedFields(
        state,
        purchaseSubmitting: purchaseSubmitting,
        purchaseError: purchaseError,
      ),
    );
  }
}

class RewardsWalletLoading extends RewardsState {
  RewardsWalletLoading._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsWalletLoading.from(
    RewardsState state, {
    bool? walletLoading,
    Object? walletError = RewardsState._unset,
  }) {
    return RewardsWalletLoading._(
      _updatedFields(state, walletLoading: walletLoading, walletError: walletError),
    );
  }
}

class RewardsWalletLoaded extends RewardsState {
  RewardsWalletLoaded._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsWalletLoaded.from(
    RewardsState state, {
    Wallet? wallet,
    bool? walletLoading,
    Object? walletError = RewardsState._unset,
  }) {
    return RewardsWalletLoaded._(
      _updatedFields(state, wallet: wallet, walletLoading: walletLoading, walletError: walletError),
    );
  }
}

class RewardsWalletError extends RewardsState {
  RewardsWalletError._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardsWalletError.from(
    RewardsState state, {
    bool? walletLoading,
    Object? walletError = RewardsState._unset,
  }) {
    return RewardsWalletError._(
      _updatedFields(state, walletLoading: walletLoading, walletError: walletError),
    );
  }
}

class RewardPurchaseFeedbackCleared extends RewardsState {
  RewardPurchaseFeedbackCleared._(_RewardsStateFields fields) : super.fromFields(fields);

  factory RewardPurchaseFeedbackCleared.from(
    RewardsState state, {
    Object? purchaseError = RewardsState._unset,
    Object? lastPurchase = RewardsState._unset,
  }) {
    return RewardPurchaseFeedbackCleared._(
      _updatedFields(state, purchaseError: purchaseError, lastPurchase: lastPurchase),
    );
  }
}
