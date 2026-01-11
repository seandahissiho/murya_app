import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/module.dart';

class RessourcesModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;
  final Widget? dragHandle;
  final GlobalKey? tileKey;
  final EdgeInsetsGeometry cardMargin;

  const RessourcesModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
    this.dragHandle,
    this.tileKey,
    this.cardMargin = const EdgeInsets.all(4),
  });

  @override
  State<RessourcesModuleWidget> createState() => _RessourcesModuleWidgetState();
}

class _RessourcesModuleWidgetState extends State<RessourcesModuleWidget> {
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
              module: widget.module,
              content: null,
              // backgroundImage: AppImages.homeBox3Path,
              onSizeChanged: widget.onSizeChanged,
              dragHandle: widget.dragHandle,
              tileKey: widget.tileKey,
              cardMargin: widget.cardMargin,
            );
          },
        );
      },
    );
  }
}

class RessourcesModuleContent extends StatelessWidget {
  final User user;

  const RessourcesModuleContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
