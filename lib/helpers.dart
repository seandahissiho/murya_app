import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:url_launcher/url_launcher.dart';

double measureTextWidth(String text, TextStyle style) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout(); // performs the layout
  return textPainter.width;
}

Future<bool> isValidPhoneNumber(String phoneNumber) async {
  try {
    String phoneNumberParsed = phoneNumber.noSpace();
    PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumberParsed);
    PhoneNumberType type = await PhoneNumber.getPhoneNumberType(phoneNumberParsed, number.isoCode!);
    String parsableNumber = number.parseNumber();
    return phoneNumberParsed.contains(parsableNumber.replaceAll("+", "")) && type == PhoneNumberType.MOBILE;
  } catch (e) {
    return false;
  }
}

Future<void> openUrl(String? url) async {
  if (url == null || url.isEmpty) {
    return;
  }
  Uri uri = Uri.parse(url.noSpace());

  if (await canLaunchUrl(uri)) {
    // Launch the URL in the browser
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Use external browser
    );
  } else {
    throw 'Could not launch $url';
  }
}

bool _navInFlight = false;
DateTime? _lastNavAt;
const Duration _navCooldown = Duration(milliseconds: 500);
const Duration _navDelay = Duration(milliseconds: 250);

void navigateToPath(BuildContext context, {String? from, required String to, Object? data}) {
  final now = DateTime.now();
  if (_navInFlight) return;
  if (_lastNavAt != null && now.difference(_lastNavAt!) < _navCooldown) return;

  final beamer = Beamer.of(context);
  final Uri currentUri = beamer.currentBeamLocation.state.routeInformation.uri;
  final Uri? targetUri = Uri.tryParse(to);
  if (targetUri != null &&
      currentUri.path == targetUri.path &&
      currentUri.query == targetUri.query &&
      currentUri.fragment == targetUri.fragment) {
    return;
  }

  _navInFlight = true;
  _lastNavAt = now;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(_navDelay, () {
      if (!context.mounted) {
        _navInFlight = false;
        return;
      }
      try {
        context.read<AppBloc>().add(
              AppChangeRoute(
                currentRoute: from ?? to,
                nextRoute: to,
              ),
            );
        // final Uri? uri = Uri.tryParse(to);
        // // log("Beaming to: ${widget.parent.route!} with URI: $uri");
        // Beamer.of(context).updateRouteInformation(RouteInformation(
        //   uri: uri,
        // ));
        beamer.beamToNamed(to, data: {
          'data': data,
        });
      } finally {
        _navInFlight = false;
      }
    });
  });
}

/// Route that slides in from the right, full screen.
class FullScreenModalRoute<T> extends PageRoute<T> {
  final Widget child;

  FullScreenModalRoute({required this.child});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => true;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Slide from right to left on enter, reverse on pop
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
