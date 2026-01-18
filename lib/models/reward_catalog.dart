import 'package:flutter/foundation.dart';
import 'package:murya/models/reward.dart';

@immutable
class RewardCatalog {
  final List<RewardItem> items;
  final int page;
  final int limit;
  final int total;

  const RewardCatalog({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory RewardCatalog.empty() => const RewardCatalog(
        items: [],
        page: 1,
        limit: 20,
        total: 0,
      );

  factory RewardCatalog.fromJson(Map<String, dynamic> json) {
    final rawItems = json["items"];
    final items = (rawItems is List ? rawItems : const [])
        .whereType<Map>()
        .map((item) => RewardItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    return RewardCatalog(
      items: items,
      page: _toInt(json["page"] ?? 1),
      limit: _toInt(json["limit"] ?? items.length),
      total: _toInt(json["total"] ?? items.length),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
