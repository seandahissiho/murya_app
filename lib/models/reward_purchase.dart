import 'package:flutter/foundation.dart';

@immutable
class RewardSummary {
  final String id;
  final String title;

  const RewardSummary({
    required this.id,
    required this.title,
  });

  factory RewardSummary.fromJson(Map<String, dynamic> json) {
    return RewardSummary(
      id: (json["id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
    };
  }
}

@immutable
class RewardPurchase {
  final String id;
  final String status;
  final int totalCostDiamonds;
  final String? voucherCode;
  final String? voucherLink;
  final RewardSummary reward;

  const RewardPurchase({
    required this.id,
    required this.status,
    required this.totalCostDiamonds,
    required this.voucherCode,
    required this.voucherLink,
    required this.reward,
  });

  bool get isReady => status.toUpperCase() == "READY";
  bool get isFulfilling => status.toUpperCase() == "FULFILLING";

  factory RewardPurchase.fromJson(Map<String, dynamic> json) {
    return RewardPurchase(
      id: (json["id"] ?? "").toString(),
      status: (json["status"] ?? "").toString(),
      totalCostDiamonds: _toInt(json["totalCostDiamonds"]),
      voucherCode: json["voucherCode"]?.toString(),
      voucherLink: json["voucherLink"]?.toString(),
      reward: RewardSummary.fromJson(
        Map<String, dynamic>.from(json["reward"] ?? const {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "status": status,
      "totalCostDiamonds": totalCostDiamonds,
      "voucherCode": voucherCode,
      "voucherLink": voucherLink,
      "reward": reward.toJson(),
    };
  }
}

@immutable
class RewardPurchaseList {
  final List<RewardPurchase> items;
  final int page;
  final int limit;
  final int total;

  const RewardPurchaseList({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory RewardPurchaseList.empty() => const RewardPurchaseList(
        items: [],
        page: 1,
        limit: 20,
        total: 0,
      );

  factory RewardPurchaseList.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items = (rawItems is List ? rawItems : const [])
        .whereType<Map>()
        .map((item) => RewardPurchase.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return RewardPurchaseList(
      items: items,
      page: _toInt(json["page"] ?? 1),
      limit: _toInt(json["limit"] ?? items.length),
      total: _toInt(json["total"] ?? items.length),
    );
  }
}

@immutable
class Wallet {
  final int diamonds;

  const Wallet({
    required this.diamonds,
  });

  factory Wallet.empty() => const Wallet(diamonds: 0);

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      diamonds: _toInt(json["diamonds"]),
    );
  }
}

@immutable
class RewardPurchaseResult {
  final RewardPurchase purchase;
  final Wallet wallet;

  const RewardPurchaseResult({
    required this.purchase,
    required this.wallet,
  });

  factory RewardPurchaseResult.fromJson(Map<String, dynamic> json) {
    return RewardPurchaseResult(
      purchase: RewardPurchase.fromJson(Map<String, dynamic>.from(json["purchase"] ?? const {})),
      wallet: Wallet.fromJson(Map<String, dynamic>.from(json["wallet"] ?? const {})),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
