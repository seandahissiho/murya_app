import 'package:dio/dio.dart';
import 'package:murya/models/reward.dart';
import 'package:murya/models/reward_catalog.dart';
import 'package:murya/models/reward_purchase.dart';
import 'package:murya/repositories/base.repository.dart';
import 'package:murya/services/cache.service.dart';

class RewardsRepository extends BaseRepository {
  final CacheService cacheService;

  RewardsRepository({CacheService? cacheService}) : cacheService = cacheService ?? CacheService();

  String _rewardsCacheKey({
    String? city,
    String? kind,
    bool? onlyAvailable,
    int page = 1,
    int limit = 20,
  }) {
    final cityKey = city != null && city.isNotEmpty ? city : 'null';
    final kindKey = kind != null && kind.isNotEmpty ? kind : 'null';
    final availKey = onlyAvailable == null ? 'null' : onlyAvailable.toString();
    return 'rewards_catalog_${cityKey}_${kindKey}_${availKey}_${page}_$limit';
  }

  String _rewardItemKey(String rewardId) => 'reward_item_$rewardId';

  String _purchasesKey({int page = 1, int limit = 20}) => 'reward_purchases_${page}_$limit';

  String _purchaseKey(String purchaseId) => 'reward_purchase_$purchaseId';

  String _walletKey() => 'reward_wallet';

  Future<Result<RewardCatalog>> getRewards({
    String? city,
    String? kind,
    bool? onlyAvailable,
    int page = 1,
    int limit = 20,
  }) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get(
          '/rewards',
          queryParameters: {
            if (city != null && city.isNotEmpty) 'city': city,
            if (kind != null && kind.isNotEmpty) 'kind': kind,
            if (onlyAvailable != null) 'onlyAvailable': onlyAvailable,
            'page': page,
            'limit': limit,
          },
        );
        final raw = _extractData(response.data);
        if (raw is List) {
          final items =
              raw.whereType<Map>().map((item) => RewardItem.fromJson(Map<String, dynamic>.from(item))).toList();
          await cacheService.save(
            _rewardsCacheKey(
              city: city,
              kind: kind,
              onlyAvailable: onlyAvailable,
              page: page,
              limit: limit,
            ),
            {
              'items': raw.whereType<Map>().toList(),
              'page': page,
              'limit': limit,
              'total': items.length,
            },
          );
          return RewardCatalog(
            items: items,
            page: page,
            limit: limit,
            total: items.length,
          );
        }
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        await cacheService.save(
          _rewardsCacheKey(
            city: city,
            kind: kind,
            onlyAvailable: onlyAvailable,
            page: page,
            limit: limit,
          ),
          data,
        );
        return RewardCatalog.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getRewards',
      errorResult: RewardCatalog.empty(),
    );
  }

  Future<Result<RewardCatalog>> getRewardsCached({
    String? city,
    String? kind,
    bool? onlyAvailable,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cachedData = await cacheService.get(
        _rewardsCacheKey(
          city: city,
          kind: kind,
          onlyAvailable: onlyAvailable,
          page: page,
          limit: limit,
        ),
      );
      if (cachedData != null) {
        return Result.success(RewardCatalog.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  Future<Result<RewardItem>> getRewardById(String rewardId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/rewards/$rewardId');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        await cacheService.save(_rewardItemKey(rewardId), data);
        return RewardItem.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getRewardById',
      errorResult: const RewardItem(
        id: "",
        title: "",
        kind: RewardKind.other,
        city: "",
        imageUrl: "",
        address: RewardAddress(
          line1: "",
          postalCode: "",
          city: "",
          googleMapsUrl: "",
        ),
        remainingPlaces: 0,
        costDiamonds: 0,
      ),
    );
  }

  Future<Result<RewardItem>> getRewardByIdCached(String rewardId) async {
    try {
      final cachedData = await cacheService.get(_rewardItemKey(rewardId));
      if (cachedData != null) {
        return Result.success(RewardItem.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  Future<Result<RewardPurchaseList>> getPurchases({
    int page = 1,
    int limit = 20,
  }) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get(
          '/me/reward-purchases',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );
        final raw = _extractData(response.data);
        if (raw is List) {
          final items =
              raw.whereType<Map>().map((item) => RewardPurchase.fromJson(Map<String, dynamic>.from(item))).toList();
          await cacheService.save(
            _purchasesKey(page: page, limit: limit),
            {
              'items': raw.whereType<Map>().toList(),
              'page': page,
              'limit': limit,
              'total': items.length,
            },
          );
          return RewardPurchaseList(
            items: items,
            page: page,
            limit: limit,
            total: items.length,
          );
        }
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        await cacheService.save(_purchasesKey(page: page, limit: limit), data);
        return RewardPurchaseList.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getPurchases',
      errorResult: RewardPurchaseList.empty(),
    );
  }

  Future<Result<RewardPurchaseList>> getPurchasesCached({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cachedData = await cacheService.get(_purchasesKey(page: page, limit: limit));
      if (cachedData != null) {
        return Result.success(RewardPurchaseList.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  Future<Result<RewardPurchase>> getPurchaseById(String purchaseId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/me/reward-purchases/$purchaseId');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        await cacheService.save(_purchaseKey(purchaseId), data);
        return RewardPurchase.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getPurchaseById',
      errorResult: const RewardPurchase(
        id: "",
        status: "",
        totalCostDiamonds: 0,
        voucherCode: null,
        voucherLink: null,
        reward: RewardSummary(id: "", title: ""),
      ),
    );
  }

  Future<Result<RewardPurchase>> getPurchaseByIdCached(String purchaseId) async {
    try {
      final cachedData = await cacheService.get(_purchaseKey(purchaseId));
      if (cachedData != null) {
        return Result.success(RewardPurchase.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  Future<Result<RewardPurchaseResult>> purchaseReward({
    required String rewardId,
    required String idempotencyKey,
    int quantity = 1,
  }) async {
    try {
      final response = await api.dio.post(
        '/rewards/$rewardId/purchase',
        data: {
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'Idempotency-Key': idempotencyKey,
          },
        ),
      );
      final raw = _extractData(response.data);
      final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
      return Result.success(RewardPurchaseResult.fromJson(data), null);
    } on DioException catch (error) {
      final replay = _extractReplayPurchase(error);
      if (replay != null) {
        return Result.success(replay, null);
      }
      return Result.failure(_extractErrorMessage(error) ?? "Une erreur est survenue");
    } catch (_) {
      return Result.failure("Une erreur est survenue");
    }
  }

  Future<Result<Wallet>> getWallet() async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/me/wallet');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        await cacheService.save(_walletKey(), data);
        return Wallet.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getWallet',
      errorResult: Wallet.empty(),
    );
  }

  Future<Result<Wallet>> getWalletCached() async {
    try {
      final cachedData = await cacheService.get(_walletKey());
      if (cachedData != null) {
        return Result.success(Wallet.fromJson(Map<String, dynamic>.from(cachedData)), null);
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success(null, null);
  }

  dynamic _extractData(dynamic raw) {
    if (raw is Map && raw.containsKey('data')) {
      return raw['data'];
    }
    return raw;
  }

  RewardPurchaseResult? _extractReplayPurchase(DioException error) {
    if (error.response?.statusCode != 409) {
      return null;
    }
    final raw = error.response?.data;
    if (raw is! Map) {
      return null;
    }
    final data = _extractData(raw);
    if (data is Map && data.containsKey('purchase')) {
      return RewardPurchaseResult.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  String? _extractErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return (data["error"] ?? data["message"] ?? data["code"])?.toString();
    }
    return null;
  }
}
