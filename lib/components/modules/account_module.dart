import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/module.dart';

class AccountModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;

  const AccountModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
  });

  @override
  State<AccountModuleWidget> createState() => _AccountModuleWidgetState();
}

class _AccountModuleWidgetState extends State<AccountModuleWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModulesBloc, ModulesState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        return BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            setState(() {});
          },
          builder: (context, state) {
            return AppModuleWidget(
              backgroundImage: AppImages.homeBox1Path,
              module: widget.module,
              content: state.user.isRegistered ? ProfileModuleContent(user: state.user) : null,
              onSizeChanged: widget.onSizeChanged,
            );
          },
        );
      },
    );
  }
}

class ProfileModuleContent extends StatelessWidget {
  final User user;

  const ProfileModuleContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
