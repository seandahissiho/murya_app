import 'dart:math' as math;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/components/score.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/models/module.dart';

class AccountModuleWidget extends StatefulWidget {
  final Module module;
  final VoidCallback? onSizeChanged;
  final Widget? dragHandle;
  final GlobalKey? tileKey;
  final EdgeInsetsGeometry cardMargin;

  const AccountModuleWidget({
    super.key,
    required this.module,
    this.onSizeChanged,
    this.dragHandle,
    this.tileKey,
    this.cardMargin = const EdgeInsets.all(4),
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
            final user = state.user;
            final hasData = user.isRegistered;
            final buttonText = widget.module.button1Text(context);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 2500),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: AppModuleWidget(
                key: ValueKey('account-module-${widget.module.id}-${hasData ? "data" : "empty"}'),
                module: widget.module,
                hasData: true,
                titleContent: widget.module.title(context),
                subtitleContent: hasData ? GoalWidget(value: _goalValue(user)) : const GoalWidget(value: 0),
                bodyContent: AccountBodyContent(
                  user: user,
                  module: widget.module,
                ),
                footerContent: buttonText == null
                    ? null
                    : AppXButton(
                        shrinkWrap: false,
                        onPressed: widget.module.button1OnPressed(context),
                        isLoading: false,
                        text: buttonText,
                      ),
                onSizeChanged: widget.onSizeChanged,
                dragHandle: widget.dragHandle,
                tileKey: widget.tileKey,
                cardMargin: widget.cardMargin,
              ),
            );
          },
        );
      },
    );
  }

  int _goalValue(User user) {
    return 0;
  }
}

class AccountBodyContent extends StatelessWidget {
  final Module module;
  final User user;

  const AccountBodyContent({super.key, required this.user, required this.module});

  @override
  Widget build(BuildContext context) {
    final String firstName = user.firstName ?? '';
    final String lastName = user.lastName ?? '';
    final String rawName = '$firstName $lastName'.trim();
    final String fullName = rawName.isNotEmpty ? rawName : 'Prénom Nom';
    final String? photoUrl = user.photoURL;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double scale = _contentScale(constraints);
        final double nameFontSize = _nameFontSize(scale);
        final double nameMinFontSize = math.min(10.0, nameFontSize);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: module.boxType != AppModuleType.type1 && module.boxType != AppModuleType.type1_2
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                _AvatarPhoto(photoUrl: photoUrl, module: module, scale: scale),
                if (module.boxType == AppModuleType.type1 || module.boxType == AppModuleType.type1_2) ...[
                  SizedBox(height: AppSpacing.groupMargin * scale, width: AppSpacing.groupMargin * scale),
                  AutoSizeText(
                    fullName,
                    style: GoogleFonts.anton(
                      fontSize: nameFontSize,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    minFontSize: nameMinFontSize,
                  ),
                ],
              ],
            ),
            _upperSpacer(scale),
            if (module.boxType != AppModuleType.type1 && module.boxType != AppModuleType.type1_2)
              Center(
                child: AutoSizeText(
                  fullName,
                  style: GoogleFonts.anton(
                    fontSize: nameFontSize,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  minFontSize: nameMinFontSize,
                ),
              ),
            _bottomSpacer(scale),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.errorDefault),
                  borderRadius: AppRadius.tiny,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _contentScale(BoxConstraints constraints) {
    final double nonFlexHeight = _baseNonFlexHeight();
    if (nonFlexHeight <= 0) {
      return 1.0;
    }
    return math.min(1.0, constraints.maxHeight / nonFlexHeight);
  }

  double _baseNonFlexHeight() {
    final bool inlineName = module.boxType == AppModuleType.type1 || module.boxType == AppModuleType.type1_2;
    final double avatarHeight = _baseAvatarHeight();
    final double nameHeight = _baseNameFontSize() + 4;
    final double rowHeight = inlineName ? math.max(avatarHeight, nameHeight) : avatarHeight;
    final double extraNameHeight = inlineName ? 0 : nameHeight;
    return rowHeight + _baseUpperSpacer() + extraNameHeight + _baseBottomSpacer() + 15;
  }

  Widget _upperSpacer(double scale) {
    return SizedBox(height: _baseUpperSpacer() * scale);
  }

  double _baseUpperSpacer() {
    if (module.boxType == AppModuleType.type2_2) {
      return 32;
    }
    if (module.boxType == AppModuleType.type2_1) {
      return 16;
    }
    if (module.boxType == AppModuleType.type1_2) {
      return 4;
    }
    return 4;
  }

  Widget _bottomSpacer(double scale) {
    return SizedBox(height: _baseBottomSpacer() * scale);
  }

  double _baseBottomSpacer() {
    if (module.boxType == AppModuleType.type2_2) {
      return 32;
    }
    if (module.boxType == AppModuleType.type2_1) {
      return 16;
    }
    if (module.boxType == AppModuleType.type1_2) {
      return 4;
    }
    return 4;
  }

  double _nameFontSize(double scale) {
    return _baseNameFontSize() * scale;
  }

  double _baseNameFontSize() {
    if (module.boxType == AppModuleType.type2_2) {
      return 28.0;
    }
    if (module.boxType == AppModuleType.type2_1) {
      return 28.0;
    }
    if (module.boxType == AppModuleType.type1_2) {
      return 20.0;
    }
    return 16.0;
  }

  double _baseAvatarHeight() {
    if (module.boxType == AppModuleType.type2_2) {
      return 131;
    }
    if (module.boxType == AppModuleType.type2_1) {
      return 124;
    }
    if (module.boxType == AppModuleType.type1_2) {
      return 48;
    }
    return 32;
  }
}

class _AvatarPhoto extends StatelessWidget {
  final String? photoUrl;
  final Module module;
  final double scale;

  const _AvatarPhoto({
    required this.photoUrl,
    required this.module,
    required this.scale,
  });

  double _avatarHeight(BoxConstraints constraints) {
    if (module.boxType == AppModuleType.type2_2) {
      return 131;
    }
    if (module.boxType == AppModuleType.type2_1) {
      return 124;
    }
    if (module.boxType == AppModuleType.type1_2) {
      return 48;
    }
    return 32;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
        final double size = _avatarHeight(constraints) * scale;
        if (photoUrl == null || photoUrl!.isEmpty) {
          return CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.whiteSwatch,
            backgroundImage: const AssetImage(
              AppImages.avatarPlaceholder,
            ),
          );
        }
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.whiteSwatch,
          child: ClipOval(
            child: Image.network(
              photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.person_outline,
                  color: AppColors.textTertiary,
                  size: size / 2,
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
