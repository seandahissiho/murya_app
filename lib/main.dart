import 'package:beamer/beamer.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:murya/analytics/analytics_service.dart';
import 'package:murya/app.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;

final Faker FAKER = Faker();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = true;
  tz_data.initializeTimeZones();

  await dotenv.load(
    fileName: ".env",
  );
  await AnalyticsService.instance.init();

  Beamer.setPathUrlStrategy();
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  Intl.defaultLocale = Intl.canonicalizedLocale(systemLocale.toLanguageTag());

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}
