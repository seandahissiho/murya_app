import 'dart:async';

import 'package:diacritic/diacritic.dart' show removeDiacritics;
import 'package:flutter/material.dart';
import 'package:murya/models/country.dart';

abstract class SearchService<T> {
  FutureOr<List<T>> find(String search, BuildContext context) async {
    throw UnimplementedError('This method should be overridden in subclasses');
  }

  // createFromName
  FutureOr<T> createFromName(String name, BuildContext context, {dynamic data}) async {
    throw UnimplementedError('This method should be overridden in subclasses');
  }
}

class CountryService extends SearchService<AppCountry> {
  @override
  List<AppCountry> find(String search, BuildContext context) {
    return frCountryList.where((country) {
      final normalizedSearch = removeDiacritics((search.toLowerCase()));
      final normalizedCountryName = removeDiacritics((country.name.toLowerCase()));
      return normalizedCountryName.contains(normalizedSearch);
    }).toList();
  }
}
