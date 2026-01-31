import 'package:beamer/beamer.dart';
import 'package:equatable/equatable.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:murya/app.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:provider/provider.dart';

final Faker FAKER = Faker();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  EquatableConfig.stringify = true;

  await dotenv.load(
    fileName: ".env",
  );

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
