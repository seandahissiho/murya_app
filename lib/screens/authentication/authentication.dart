import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/screens/base.dart';

part '_authentication_mobile.dart';
part '_authentication_tablet+.dart';

enum AuthenticationTab {
  login,
  register,
}

int _tabIndex(AuthenticationTab tab) => tab == AuthenticationTab.login ? 0 : 1;

class LoginLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.login];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('login-page-$languageCode'),
        title: 'Murya - Connexion',
        child: const AuthenticationScreen(initialTab: AuthenticationTab.login),
      ),
    ];
  }
}

class RegisterLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.register];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('register-page-$languageCode'),
        title: 'Murya - Inscription',
        child: const AuthenticationScreen(initialTab: AuthenticationTab.register),
      ),
    ];
  }
}

class ForgotPasswordLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.forgotPassword];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      BeamPage(
        key: ValueKey('forgot-password-page-$languageCode'),
        title: 'Murya - Mot de passe oublié',
        child: const ForgotPasswordScreen(),
      ),
    ];
  }
}

class AuthenticationScreen extends StatelessWidget {
  final AuthenticationTab initialTab;

  const AuthenticationScreen({super.key, required this.initialTab});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      mobileScreen: MobileAuthenticationScreen(initialTab: initialTab),
      tabletScreen: TabletAuthenticationScreen(initialTab: initialTab),
      desktopScreen: TabletAuthenticationScreen(initialTab: initialTab),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseScreen(
      mobileScreen: MobileForgotPasswordScreen(),
      tabletScreen: TabletForgotPasswordScreen(),
      desktopScreen: TabletForgotPasswordScreen(),
    );
  }
}
