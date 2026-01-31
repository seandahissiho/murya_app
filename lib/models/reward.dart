import 'package:flutter/foundation.dart';
import 'package:murya/l10n/l10n.dart';

@immutable
class RewardAddress {
  final String? id;

  /// Ex: "34 Boulevard Chasseigne"
  final String line1;

  /// Ex: "86000"
  final String postalCode;

  /// Ex: "Poitiers"
  final String city;

  /// Ex: "France"
  final String country;

  /// Lien Google Maps “ready-to-open”
  final String googleMapsUrl;

  /// Optionnel (utile pour affichage map, tri distance, etc.)
  final double? lat;
  final double? lng;

  const RewardAddress({
    this.id,
    required this.line1,
    required this.postalCode,
    required this.city,
    this.country = "France",
    required this.googleMapsUrl,
    this.lat,
    this.lng,
  });

  String get fullAddress => "$line1, $postalCode $city, $country";

  factory RewardAddress.fromJson(Map<String, dynamic> json) {
    return RewardAddress(
      id: json["id"]?.toString(),
      line1: (json["line1"] ?? json["street"] ?? "").toString(),
      postalCode: (json["postalCode"] ?? json["zip"] ?? "").toString(),
      city: (json["city"] ?? "").toString(),
      country: (json["country"] ?? json["countryId"] ?? "France").toString(),
      googleMapsUrl: (json["googleMapsUrl"] ?? "").toString(),
      lat: (json["lat"] as num?)?.toDouble(),
      lng: (json["lng"] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "line1": line1,
      "postalCode": postalCode,
      "city": city,
      "country": country,
      "googleMapsUrl": googleMapsUrl,
      "lat": lat,
      "lng": lng,
    };
  }
}

/// Ex: "Cinéma", "Salle de concert", etc.
enum RewardKind {
  cinema,
  concertHall,
  theatre,
  sportsMatch,
  themePark,
  other,
}

extension RewardKindX on RewardKind {
  String label(AppLocalizations locale) {
    switch (this) {
      case RewardKind.cinema:
        return locale.rewardKind_cinema;
      case RewardKind.concertHall:
        return locale.rewardKind_concertHall;
      case RewardKind.theatre:
        return locale.rewardKind_theatre;
      case RewardKind.sportsMatch:
        return locale.rewardKind_sportsMatch;
      case RewardKind.themePark:
        return locale.rewardKind_themePark;
      case RewardKind.other:
        return locale.rewardKind_other;
    }
  }

  String toJson() => name;

  static RewardKind fromJson(String? value) {
    if (value == null) return RewardKind.other;
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case "cinema":
        return RewardKind.cinema;
      case "concert_hall":
      case "concert-hall":
      case "concert":
      case "concert hall":
        return RewardKind.concertHall;
      case "theatre":
      case "theater":
        return RewardKind.theatre;
      case "sports_match":
      case "sports-match":
      case "sports match":
        return RewardKind.sportsMatch;
      case "theme_park":
      case "theme-park":
      case "theme park":
        return RewardKind.themePark;
      default:
        return RewardKind.values.firstWhere(
          (e) => e.name == normalized,
          orElse: () => RewardKind.other,
        );
    }
  }
}

@immutable
class RewardItem {
  final String id;
  final String code;
  final String title;
  final String description;
  final RewardKind kind;
  final String city;
  final String imageUrl;

  /// ✅ NOUVEAU
  final RewardAddress address;

  final int remainingPlaces;
  final int costDiamonds;
  final bool isUnlocked;
  final String fulfillmentMode;
  final String redeemMethod;
  final bool canBuy;
  final String? canBuyReason;

  const RewardItem({
    required this.id,
    this.code = "",
    required this.title,
    this.description = "",
    required this.kind,
    required this.city,
    required this.imageUrl,
    required this.address,
    required this.remainingPlaces,
    required this.costDiamonds,
    this.isUnlocked = false,
    this.fulfillmentMode = "",
    this.redeemMethod = "",
    this.canBuy = true,
    this.canBuyReason,
  });

  String subtitle(AppLocalizations locale) => "${kind.label(locale)} - $city";

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    final user = (json["user"] as Map<String, dynamic>?) ?? const {};
    return RewardItem(
      id: (json["id"] ?? "").toString(),
      code: (json["code"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      kind: RewardKindX.fromJson(json["kind"]?.toString()),
      city: (json["city"] ?? "").toString(),
      imageUrl: (json["imageUrl"] ?? "").toString(),
      address: RewardAddress.fromJson((json["address"] ?? {}) as Map<String, dynamic>),
      remainingPlaces: _toInt(json["remainingStock"] ?? json["remainingPlaces"]),
      costDiamonds: _toInt(json["costDiamonds"]),
      isUnlocked: (json["isUnlocked"] ?? false) as bool,
      fulfillmentMode: (json["fulfillmentMode"] ?? "").toString(),
      redeemMethod: (json["redeemMethod"] ?? "").toString(),
      canBuy: (user["canBuy"] as bool?) ?? true,
      canBuyReason: user["reason"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code,
      "title": title,
      "description": description,
      "kind": kind.toJson(),
      "city": city,
      "imageUrl": imageUrl,
      "address": address.toJson(),
      "remainingPlaces": remainingPlaces,
      "costDiamonds": costDiamonds,
      "isUnlocked": isUnlocked,
      "fulfillmentMode": fulfillmentMode,
      "redeemMethod": redeemMethod,
      "user": {
        "canBuy": canBuy,
        "reason": canBuyReason,
      },
    };
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
