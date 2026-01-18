import 'package:dio/dio.dart';
import 'package:murya/models/reward.dart';
import 'package:murya/models/reward_catalog.dart';
import 'package:murya/models/reward_purchase.dart';
import 'package:murya/repositories/base.repository.dart';

class RewardsRepository extends BaseRepository {
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
          '/api/rewards',
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
          final items = raw
              .whereType<Map>()
              .map((item) => RewardItem.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return RewardCatalog(
            items: items,
            page: page,
            limit: limit,
            total: items.length,
          );
        }
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        return RewardCatalog.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getRewards',
      errorResult: RewardCatalog.empty(),
    );
  }

  Future<Result<RewardItem>> getRewardById(String rewardId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/api/rewards/$rewardId');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
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

  Future<Result<RewardPurchaseList>> getPurchases({
    int page = 1,
    int limit = 20,
  }) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get(
          '/api/me/reward-purchases',
          queryParameters: {
            'page': page,
            'limit': limit,
          },
        );
        final raw = _extractData(response.data);
        if (raw is List) {
          final items = raw
              .whereType<Map>()
              .map((item) => RewardPurchase.fromJson(Map<String, dynamic>.from(item)))
              .toList();
          return RewardPurchaseList(
            items: items,
            page: page,
            limit: limit,
            total: items.length,
          );
        }
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        return RewardPurchaseList.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getPurchases',
      errorResult: RewardPurchaseList.empty(),
    );
  }

  Future<Result<RewardPurchase>> getPurchaseById(String purchaseId) async {
    return AppResponse.execute(
      action: () async {
        final response = await api.dio.get('/api/me/reward-purchases/$purchaseId');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
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

  Future<Result<RewardPurchaseResult>> purchaseReward({
    required String rewardId,
    required String idempotencyKey,
    int quantity = 1,
  }) async {
    try {
      final response = await api.dio.post(
        '/api/rewards/$rewardId/purchase',
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
        final response = await api.dio.get('/api/me/wallet');
        final raw = _extractData(response.data);
        final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
        return Wallet.fromJson(data);
      },
      parentFunctionName: 'RewardsRepository.getWallet',
      errorResult: Wallet.empty(),
    );
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
