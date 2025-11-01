import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:diacritic/diacritic.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:sealed_countries/sealed_countries.dart'
    show LangFra, BasicTypedLocale, WorldCountry, TranslatedExtension, CountryNameExtension;

/// Construit une Map des noms français vers les noms anglais de tous les pays.
Map<String, String> buildFrToEnCountryMap() {
  // Locale français typé pour les traductions
  const frLocale = BasicTypedLocale(LangFra());

  final Map<String, String> frToEn = {};

  for (final WorldCountry country in WorldCountry.list) {
    // Récupère le nom courant en français (ou null si absent)
    final frName = removeDiacritics(country.maybeCommonNameFor(frLocale)?.toLowerCase() ?? '');
    if (frName.isNotEmpty) {
      // Mappe le nom français au nom anglais
      frToEn[frName] = country.name.common.toLowerCase();
    }
  }

  return frToEn;
}

List<AppCountry> buildFrCountryList() {
  final List<AppCountry> pays = [];
  const frLocale = BasicTypedLocale(LangFra());

  for (final WorldCountry country in WorldCountry.list) {
    final String frName = country.maybeCommonNameFor(frLocale)?.toLowerCase() ?? 'NULL';
    final AppCountry newCountry = AppCountry(
      phoneCode: country.codeNumeric,
      name: frName,
      isoCode: country.code,
      iso3Code: country.codeShort,
    );

    pays.add(newCountry);
  }

  return pays;
}

final Map<String, String> FR_TO_EN_COUNTRY_MAP = buildFrToEnCountryMap();

final List<AppCountry> frCountryList = buildFrCountryList();

/// Returns the ISO alpha-2 code (e.g. "US", "FR") for a given country name,
/// or null if no match is found.
String? getCountryIsoCode(String countryName) {
  String enName =
      (FR_TO_EN_COUNTRY_MAP[removeDiacritics(countryName.toLowerCase().trim())] ?? countryName).toLowerCase().trim();
  try {
    final country = countryList.firstWhere(
      (c) => c.name.toLowerCase().trim() == enName,
    );
    return country.isoCode;
  } catch (_) {
    return null;
  }
}

/// Represents a postal address with optional second street line.
class AppAddress {
  final String? id;
  final String street;
  final String? street2;
  final String city;
  final String state;
  final String zipCode;
  final AppCountry? country;

  static final AppAddress zero = AppAddress(
    street: '',
    street2: null,
    city: '',
    state: '',
    zipCode: '',
    country: null,
  );

  AppAddress({
    this.id,
    required this.street,
    this.street2,
    required this.city,
    this.state = '',
    this.zipCode = '',
    required this.country,
  });

  /// Creates a copy with updated fields.
  AppAddress copyWith({
    String? street,
    String? street2,
    String? city,
    String? state,
    String? zipCode,
    AppCountry? country,
  }) {
    return AppAddress(
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'id': id,
      'street': street,
      if (street2 != null) 'street2': street2,
      'city': city,
      'state': state,
      'zip': zipCode,
      'country': country?.toJson(),
    };

    // Remove null values
    json.removeWhere(
        (key, value) => value == null || (value is String && value.isEmpty) || (value is Map && value.isEmpty));

    return json;
  }

  /// Deserializes from JSON.
  factory AppAddress.fromJson(Map<String, dynamic> json) {
    return AppAddress(
      id: json['id'] as String?,
      street: json['street'] as String,
      street2: json['street2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String? ?? '',
      zipCode: json['zip'] as String? ?? '',
      country: json['country'] != null ? AppCountry.fromJson(json['country'] as Map<String, dynamic>) : null,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (street.isNotEmpty) parts.add(street);
    if (street2 != null && street2!.isNotEmpty) parts.add(street2!);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (zipCode.isNotEmpty) parts.add(zipCode);
    if (country?.isNotEmpty ?? false) parts.add(country!.name);

    if (parts.isEmpty) {
      return '-';
    }

    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppAddress &&
        other.street == street &&
        other.street2 == street2 &&
        other.city == city &&
        other.state == state &&
        other.zipCode == zipCode &&
        other.country == country;
  }

  @override
  int get hashCode => Object.hash(street, street2, city, state, zipCode, country);

  static empty() {
    return AppAddress(
      street: '',
      street2: null,
      city: '',
      state: '',
      zipCode: '',
      country: null,
    );
  }
}

/// Represents a language with its code (e.g., 'en') and display name.
class AppLanguage {
  final String code;
  final String name;

  // french language instance
  static const AppLanguage french = AppLanguage(code: 'fr', name: 'Français');
  // english language instance
  static const AppLanguage english = AppLanguage(code: 'en', name: 'English');

  const AppLanguage({
    required this.code,
    required this.name,
  });

  /// Creates a copy with updated fields.
  AppLanguage copyWith({
    String? code,
    String? name,
  }) {
    return AppLanguage(
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
      };

  /// Deserializes from JSON.
  factory AppLanguage.fromJson(Map<String, dynamic> json) {
    return AppLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => 'AppLanguage(code: $code, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppLanguage && other.code == code && other.name == name;
  }

  @override
  int get hashCode => Object.hash(code, name);
}

class AppCountry extends Country {
  AppCountry({
    required super.isoCode,
    required super.iso3Code,
    required super.phoneCode,
    required super.name,
  });

  factory AppCountry.fromJson(Map<String, dynamic> json) {
    return AppCountry(
      isoCode: json['isoCode'] as String,
      iso3Code: (json['iso3Code'] ?? '') as String,
      phoneCode: (json['phoneCode'] ?? '') as String,
      name: (json['name'] ?? '') as String,
    );
  }

  bool get isNotEmpty => isoCode.isNotEmpty && name.isNotEmpty;

  Map<String, dynamic> toJson() {
    assert(isoCode.isNotEmpty, "isoCode should not be empty");
    assert(name.isNotEmpty, "name should not be empty");
    assert(phoneCode.isNotEmpty, "phoneCode should not be empty");
    assert(iso3Code.isNotEmpty, "iso3Code should not be empty");
    return {
      'isoCode': isoCode,
      'iso3Code': iso3Code,
      'phoneCode': phoneCode,
      'name': name,
    };
  }
}

AppCountry? countryFromIsoCode(String isoCode) {
  if (isoCode.isEmpty) return null;
  return frCountryList.firstWhereOrNull((country) => country.isoCode == isoCode);
}
