import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/blocs/search/search_bloc.dart';
import 'package:murya/components/modals/other.dart';
import 'package:murya/components/x_text_form_field.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:sizer/sizer.dart' hide DeviceType;

part '_app_bar_mobile.dart';
part '_app_bar_tablet+.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceType = DeviceHelper.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return const MobileCustomAppBar();
      default:
        return DesktopCustomAppBar(key: ValueKey('custom-app-bar-$deviceType'));
    }
  }
}
