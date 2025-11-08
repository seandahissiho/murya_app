import 'dart:ui';

import 'package:beamer/beamer.dart';
// import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/config/theme.dart';
import 'package:murya/localization/locale_controller.dart';
import 'package:murya/main_screen.dart';
import 'package:murya/repositories/app.repository.dart';
import 'package:murya/repositories/authentication.repository.dart';
import 'package:murya/repositories/jobs.repository.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:murya/repositories/profile.repository.dart';
import 'package:murya/repositories/quiz.repository.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sizer/sizer.dart';

import 'blocs/modules/quizz/quiz_bloc.dart' show QuizBloc;
import 'config/DS.dart';
import 'l10n/l10n.dart';

List<BlocProvider> getBlocProviders(BuildContext context) {
  final List<BlocProvider<StateStreamableSource<Object?>>> sharedBlocProviders = [
    BlocProvider<NotificationBloc>(
      lazy: false,
      create: (BuildContext context) => NotificationBloc(context: context),
    ),
    BlocProvider<AppBloc>(
      lazy: false,
      create: (BuildContext context) => AppBloc(
        context: context,
      )..add(AppInitialize()),
    ),
    BlocProvider<AuthenticationBloc>(
      lazy: false,
      create: (BuildContext context) => AuthenticationBloc(
        context: context,
      )..add(AuthInitialize()),
    ),
    // ModulesBloc
    BlocProvider<ModulesBloc>(
      lazy: false,
      create: (BuildContext context) => ModulesBloc(context: context)..add(InitializeModules(context: context)),
    ),
    // Profile Bloc
    BlocProvider<ProfileBloc>(
      lazy: false,
      create: (BuildContext context) => ProfileBloc(context: context),
    ),
    // Job Bloc
    BlocProvider<JobBloc>(
      lazy: false,
      create: (BuildContext context) => JobBloc(context: context),
    ),
    // Quiz Bloc
    BlocProvider<QuizBloc>(
      lazy: false,
      create: (BuildContext context) => QuizBloc(context: context),
    ),
  ];
  return sharedBlocProviders;
}

List<RepositoryProvider> getRepositoryProviders(BuildContext context) {
  final List<RepositoryProvider<Object?>> sharedRepositoryProviders = [
    RepositoryProvider<AppRepository>(
      create: (BuildContext context) => AppRepository(),
    ),
    RepositoryProvider<AuthenticationRepository>(
      create: (BuildContext context) => AuthenticationRepository(),
    ),
    RepositoryProvider<NotificationRepository>(
      create: (BuildContext context) => NotificationRepository(),
    ),
    RepositoryProvider<ProfileRepository>(
      create: (BuildContext context) => ProfileRepository(),
    ),
    RepositoryProvider<JobRepository>(
      create: (BuildContext context) => JobRepository(),
    ),
    RepositoryProvider<QuizRepository>(
      create: (BuildContext context) => QuizRepository(),
    ),
  ];
  return sharedRepositoryProviders;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Locale? _overrideLocale;

  final beamerDelegate = BeamerDelegate(
    transitionDelegate: const NoAnimationTransitionDelegate(),
    initialPath: AppRoutes.landing, // Define the initial path
    locationBuilder: RoutesLocationBuilder(routes: {
      '*': (context, state, data) => const AppScaffold(),
    }),
    guards: [
      BeamGuard(
        pathPatterns: AppRoutes.unguardedRoutes,
        guardNonMatching: true,
        check: (context, location) {
          final result = context.isUserAuthenticated();
          if (!result) {
            context.read<AppBloc>().add(
                  AppChangeRoute(
                    currentRoute: AppRoutes.landing,
                    nextRoute: AppRoutes.landing,
                  ),
                );
          }
          return result;
        },
        beamToNamed: (origin, target) => AppRoutes.landing,
      ),
      // AdminGuard(),
      // CollaboratorGuard(),
    ],
  );

  // void _changeLocale(Locale? locale) {
  //   setState(() => _overrideLocale = locale);
  // }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context);
    beamerDelegate.addListener(() {
      debugPrint('📍 Current route: ${beamerDelegate.currentBeamLocation.state.routeInformation.uri}');
    });
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          title: 'NAVY',
          // scrollBehavior: MyCustomScrollBehavior(),
          routerDelegate: beamerDelegate,
          routeInformationParser: BeamerParser(),
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: MultiRepositoryProvider(
              providers: getRepositoryProviders(context),
              child: MultiBlocProvider(
                providers: getBlocProviders(context),
                child: child!,
              ),
            ),
            // child: child!,
            breakpoints: _buildResponsiveBreakpoints,
          ),
          theme: buildLightTheme(context),
          darkTheme: buildDarkTheme(context),
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          localizationsDelegates: const [
            // CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate, // Add this line
            AppLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (provider.locale != null) return provider.locale;
            for (var supported in supportedLocales) {
              if (supported.languageCode == locale?.languageCode) {
                return supported;
              }
            }
            return supportedLocales.first;
          },
          supportedLocales: AppLocalizations.supportedLocales,
          // auto from ARB
          locale: provider.locale, // null means follow system language
        );
      },
    );
  }

  List<Breakpoint> get _buildResponsiveBreakpoints {
    return [
      const Breakpoint(
        start: 0,
        end: AppBreakpoints.mobile,
        name: MOBILE,
      ),
      const Breakpoint(
        start: AppBreakpoints.mobile + 1,
        end: AppBreakpoints.tablet,
        name: TABLET,
      ),
      const Breakpoint(
        start: AppBreakpoints.tablet + 1,
        end: AppBreakpoints.desktop,
        name: DESKTOP,
      ),
      const Breakpoint(
        start: AppBreakpoints.desktop + 1,
        end: AppBreakpoints.largeDesktop,
        name: '4K',
      ),
    ];
  }
}

extension on BuildContext {
  isUserAuthenticated() {
    return true;
    if (!mounted) return true;
    final AuthenticationBloc bloc = read<AuthenticationBloc>();
    return bloc.state.isAuthenticated;
  }
}

ThemeData buildLightTheme(BuildContext context, {double fontSizeIndex = 0}) {
  ThemeData lightTheme = AppTheme.theme;

  lightTheme = lightTheme.copyWith(
    textTheme: AppTextThemeData.buildTheme(lightTheme, context, fontSizeIndex),
  );

  lightTheme = lightTheme.copyWith(
    elevatedButtonTheme: AppElevatedButtonStyle.buildTheme(lightTheme, context),
    textButtonTheme: AppTextButtonStyle.buildTheme(lightTheme, context),
    popupMenuTheme: AppPopupMenuThemeData.buildTheme(lightTheme, context),
    dropdownMenuTheme: AppDropdownMenuThemeData.buildTheme(lightTheme, context),
    inputDecorationTheme: AppInputDecorationTheme.buildTheme(lightTheme, context),
    tabBarTheme: AppTabBarTheme.buildTheme(lightTheme, context),
  );
  return lightTheme;
}

ThemeData buildDarkTheme(BuildContext context, {double fontSizeIndex = 0}) {
  ThemeData darkTheme = AppTheme.theme;
  darkTheme = darkTheme.copyWith(
    textTheme: AppTextThemeData.buildTheme(darkTheme, context, fontSizeIndex),
  );
  darkTheme = darkTheme.copyWith(
    elevatedButtonTheme: AppElevatedButtonStyle.buildTheme(darkTheme, context),
    textButtonTheme: AppTextButtonStyle.buildTheme(darkTheme, context),
    popupMenuTheme: AppPopupMenuThemeData.buildTheme(darkTheme, context),
    dropdownMenuTheme: AppDropdownMenuThemeData.buildTheme(darkTheme, context),
    inputDecorationTheme: AppInputDecorationTheme.buildTheme(darkTheme, context),
    tabBarTheme: AppTabBarTheme.buildTheme(darkTheme, context),
  );
  return darkTheme;
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
