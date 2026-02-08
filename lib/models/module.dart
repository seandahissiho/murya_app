import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/popup.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';

enum ModuleStatus {
  active,
  inactive,
  archived,
}

extension ModuleStatusExtension on ModuleStatus {
  String get value {
    switch (this) {
      case ModuleStatus.active:
        return "ACTIVE";
      case ModuleStatus.inactive:
        return "INACTIVE";
      case ModuleStatus.archived:
        return "ARCHIVED";
    }
  }

  static ModuleStatus? fromValue(String? value) {
    switch (value) {
      case "ACTIVE":
        return ModuleStatus.active;
      case "INACTIVE":
        return ModuleStatus.inactive;
      case "ARCHIVED":
        return ModuleStatus.archived;
    }
    return null;
  }
}

enum ModuleVisibility {
  public,
  private,
  restricted,
}

extension ModuleVisibilityExtension on ModuleVisibility {
  String get value {
    switch (this) {
      case ModuleVisibility.public:
        return "PUBLIC";
      case ModuleVisibility.private:
        return "PRIVATE";
      case ModuleVisibility.restricted:
        return "RESTRICTED";
    }
  }

  static ModuleVisibility? fromValue(String? value) {
    switch (value) {
      case "PUBLIC":
        return ModuleVisibility.public;
      case "PRIVATE":
        return ModuleVisibility.private;
      case "RESTRICTED":
        return ModuleVisibility.restricted;
    }
    return null;
  }
}

enum AppModuleType {
  // One cell
  type1,
  // Two cells
  type1_2,
  // type1_3,
  // Two cells vertical
  type2_1,
  // Four cells
  type2_2,
  // type2_3,
  // type3_1,
  // type3_2,
  // type3_3,
}

// AppModuleType extension
extension AppModuleTypeExtension on AppModuleType {
  String get name {
    switch (this) {
      case AppModuleType.type1:
        return 'type1';
      case AppModuleType.type1_2:
        return 'type1_2';
      // case AppModuleType.type1_3:
      //   return 'type1_3';
      case AppModuleType.type2_1:
        return 'type2_1';
      case AppModuleType.type2_2:
        return 'type2_2';
      // case AppModuleType.type2_3:
      //   return 'type2_3';
      // case AppModuleType.type3_1:
      //   return 'type3_1';
      // case AppModuleType.type3_2:
      //   return 'type3_2';
      // case AppModuleType.type3_3:
      //   return 'type3_3';
    }
  }

  Pair<int, int> get dimensions {
    switch (this) {
      case AppModuleType.type1:
        return Pair(1, 1);
      case AppModuleType.type1_2:
        return Pair(1, 2);
      // case AppModuleType.type1_3:
      //   return Pair(1, 3);
      case AppModuleType.type2_1:
        return Pair(2, 1);
      case AppModuleType.type2_2:
        return Pair(2, 2);
      // case AppModuleType.type2_3:
      //   return Pair(2, 3);
      // case AppModuleType.type3_1:
      //   return Pair(3, 1);
      // case AppModuleType.type3_2:
      //   return Pair(3, 2);
      // case AppModuleType.type3_3:
      //   return Pair(3, 3);
    }
  }

  get crossAxisCellCount {
    switch (this) {
      case AppModuleType.type1:
        return 1;
      case AppModuleType.type1_2:
        return 2;
      // case AppModuleType.type1_3:
      //   return 3;
      case AppModuleType.type2_1:
        return 1;
      case AppModuleType.type2_2:
        return 2;
      // case AppModuleType.type2_3:
      //   return 3;
      // case AppModuleType.type3_1:
      //   return 1;
      // case AppModuleType.type3_2:
      //   return 2;
      // case AppModuleType.type3_3:
      //   return 3;
    }
  }

  get mainAxisCellCount {
    switch (this) {
      case AppModuleType.type1:
        return 1;
      case AppModuleType.type1_2:
        return 1;
      // case AppModuleType.type1_3:
      //   return 1;
      case AppModuleType.type2_1:
        return 2;
      case AppModuleType.type2_2:
        return 2;
      // case AppModuleType.type2_3:
      //   return 2;
      // case AppModuleType.type3_1:
      //   return 3;
      // case AppModuleType.type3_2:
      //   return 3;
      // case AppModuleType.type3_3:
      //   return 3;
    }
  }
}

class Module {
  final String? id;
  final String? slug;
  final String? name;
  final String? description;
  final ModuleStatus? status;
  final ModuleVisibility? visibility;
  final bool defaultOnLanding;
  final String? createdAt;
  final String? updatedAt;
  final AppModuleType boxType;

  // final Pair<int, int> topLeftPosition;
  final int index;

  Module({
    required this.id,
    this.slug,
    this.name,
    this.description,
    this.status,
    this.visibility,
    this.defaultOnLanding = false,
    this.createdAt,
    this.updatedAt,
    this.boxType = AppModuleType.type2_2,
    required this.index,
  });

  // fromJson
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      status: ModuleStatusExtension.fromValue(json['status']),
      visibility: ModuleVisibilityExtension.fromValue(json['visibility']),
      defaultOnLanding: json['defaultOnLanding'] == true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      boxType: AppModuleType.values.firstWhere(
        (e) => e.name == json['boxType'],
        orElse: () => AppModuleType.type2_2,
      ),
      index: json['index'] ?? 0,
    );
  }

  factory Module.fromApiJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
      status: ModuleStatusExtension.fromValue(json['status']),
      visibility: ModuleVisibilityExtension.fromValue(json['visibility']),
      defaultOnLanding: json['defaultOnLanding'] == true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      index: json['order'] ?? json['index'] ?? 0,
    );
  }

  String get defaultImagePath {
    switch (slug) {
      case 'leaderboard':
        return AppImages.homeBox1Path;
      case 'daily-quiz':
        return AppImages.homeBox2Path;
      case 'learning-resources':
        return AppImages.homeBox4Path;
      // personality-tests
      case 'personality-tests':
        return AppImages.personnalityTestPngPath;
      // tool-catalog
      case 'tool-catalog':
        return AppImages.toolsCatalogPngPath;
      default:
        return AppImages.homeBox3Path;
    }
  }

  String title(BuildContext context) {
    final locale = AppLocalizations.of(context);

    switch (slug) {
      case 'leaderboard':
        return locale.landing_first_title;
      case 'daily-quiz':
        return locale.landing_second_title;
      case 'learning-resources':
        return locale.user_ressources_module_title;
      default:
        if (name != null && name!.isNotEmpty) {
          return name!;
        }
        if (slug != null && slug!.isNotEmpty) {
          return slug!;
        }
        return id ?? "";
    }
  }

  String subtitle(BuildContext context) {
    final locale = AppLocalizations.of(context);

    switch (slug) {
      case 'leaderboard':
        return locale.landing_first_subtitle;
      case 'daily-quiz':
        return locale.landing_second_subtitle;
      case 'learning-resources':
        return locale.user_ressources_module_subtitle;
      default:
        if (description != null && description!.isNotEmpty) {
          return description!;
        }
        if (slug != null && slug!.isNotEmpty && slug != name) {
          return slug!;
        }
        return "";
    }
  }

  String? button1Text(BuildContext context) {
    final locale = AppLocalizations.of(context);

    switch (slug) {
      case 'leaderboard':
        return locale.landing_first_button1;
      case 'daily-quiz':
        return locale.landing_second_button;
      case 'learning-resources':
        return locale.user_ressources_module_button;
      default:
        return null;
    }
  }

  String? button2Text(BuildContext context) {
    final locale = AppLocalizations.of(context);

    switch (slug) {
      case 'leaderboard':
        return null;
        return locale.landing_first_button2;
      case 'daily-quiz':
        return null;
      case 'learning-resources':
        return null;
      default:
        return null;
    }
  }

  VoidCallback? button1OnPressed(BuildContext context) {
    switch (slug) {
      case 'leaderboard':
        return () async {
          final isMobile = DeviceHelper.isMobile(context);
          if (isMobile) {
            return await contentNotAvailablePopup(context);
          }
          final authBloc = context.read<AuthenticationBloc>();
          final profileBloc = context.read<ProfileBloc>();
          const profileLoadTimeout = Duration(seconds: 3);
          var authState = authBloc.state;
          if (authState is AuthenticationLoading) {
            authState = await authBloc.stream.firstWhere((state) => state is! AuthenticationLoading);
          }
          if (!context.mounted) return;
          if (!authState.isAuthenticated) {
            navigateToPath(context, to: AppRoutes.login);
            return;
          }
          ProfileState profileState = profileBloc.state;
          if (profileState is! ProfileLoaded) {
            profileBloc.add(ProfileLoadEvent());
            profileState = await profileBloc.stream
                .firstWhere((state) => state is ProfileLoaded || state is ProfileInitial)
                .timeout(profileLoadTimeout, onTimeout: () => profileBloc.state);
          }
          authState = authBloc.state;
          if (!context.mounted) return;
          if (!authState.isAuthenticated) {
            navigateToPath(context, to: AppRoutes.login);
            return;
          }
          final user = profileState.user;
          if (!context.mounted) return;
          const hasEmail = true; //(user.email ?? '').isNotEmpty;
          navigateToPath(context, to: hasEmail ? AppRoutes.profile : AppRoutes.login);
        };
      case 'daily-quiz':
        return () {
          final theme = Theme.of(context);
          final locale = AppLocalizations.of(context);
          bool isMobile = DeviceHelper.isMobile(context);
          // displayPopUp(
          //   width: 736,
          //   context: context,
          //   noActions: true,
          //   contents: [
          //     Center(
          //         child: Text(locale.popup_job_selection_title,
          //             style: GoogleFonts.anton(
          //               color: AppColors.primaryDefault,
          //               fontSize: isMobile
          //                   ? theme.textTheme.headlineSmall!.fontSize!
          //                   : theme.textTheme.displaySmall!.fontSize!,
          //               fontWeight: FontWeight.w400,
          //             ))),
          //     AppSpacing.containerInsideMarginBox,
          //     Container(
          //       width: double.infinity,
          //       decoration: const BoxDecoration(
          //         borderRadius: AppRadius.borderRadius20,
          //         image: DecorationImage(
          //           image: AssetImage(AppImages.homeBox1Path),
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //       padding: const EdgeInsets.all(AppSpacing.textFieldMargin),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           SvgPicture.asset(AppIcons.cyberSecurityJobPopupIconPath),
          //           AppSpacing.textFieldMarginBox,
          //           Text(
          //             locale.popup_job_selection_technician_title,
          //             style: GoogleFonts.anton(
          //               color: AppColors.textInverted,
          //               fontSize: isMobile
          //                   ? theme.textTheme.headlineSmall!.fontSize!
          //                   : theme.textTheme.displaySmall!.fontSize!,
          //               fontWeight: FontWeight.w400,
          //             ),
          //           ),
          //           AppSpacing.tinyTinyMarginBox,
          //           Text(
          //             locale.popup_job_selection_technician_subtitle,
          //             style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textInverted),
          //             textAlign: TextAlign.start,
          //           ),
          //           AppSpacing.containerInsideMarginBox,
          //           AppXButton(
          //             shrinkWrap: false,
          //             bgColor: AppColors.textInverted,
          //             fgColor: AppColors.primaryDefault,
          //             maxWidth: double.infinity,
          //             onPressed: () {
          //               Navigator.of(context, rootNavigator: true).pop(true);
          //             },
          //             isLoading: false,
          //             text: locale.popup_job_selection_continue_button,
          //           )
          //         ],
          //       ),
          //     ),
          //     AppSpacing.containerInsideMarginBox,
          //     Container(
          //       decoration: BoxDecoration(
          //         border: Border.all(color: AppColors.borderMedium),
          //         borderRadius: AppRadius.borderRadius20,
          //       ),
          //       padding: const EdgeInsets.all(AppSpacing.textFieldMargin),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Text(
          //             locale.popup_job_selection_other_expertise_label,
          //             style: theme.textTheme.labelLarge,
          //           ),
          //           AppSpacing.containerInsideMarginSmallBox,
          //           SizedBox(
          //             height: tabletAndAboveCTAHeight,
          //             child: AppTextFormField(
          //               // maxWidth: double.infinity,
          //               autoResize: true,
          //               controller: TextEditingController(),
          //               hintText: locale.popup_job_selection_search_hint,
          //               label: null,
          //             ),
          //           ),
          //         ],
          //       ),
          //     )
          //   ],
          // ).then((value) {
          //   if (context.mounted != true) return;
          //   if (value == true) {
          //     final jobId = context.read<JobBloc>().jobs.firstOrNull?.id!;
          //     if (jobId != null) {
          //       navigateToPath(context, to: AppRoutes.jobDetails.replaceAll(':id', jobId));
          //     }
          //   }
          // });
        };
      case 'learning-resources':
        return () {
          navigateToPath(context, to: AppRoutes.userRessourcesModule);
        };
      default:
        return null;
    }
  }

  VoidCallback? button2OnPressed(BuildContext context) {
    switch (slug) {
      case 'leaderboard':
        return () {
          navigateToPath(context, to: AppRoutes.login);
        };
      case 'daily-quiz':
        return null;
      case 'learning-resources':
        return null;
      default:
        return null;
    }
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boxType': boxType.name,
      'index': index,
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'status': status?.value,
      'visibility': visibility?.value,
      'defaultOnLanding': defaultOnLanding,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  nextBoxType() {
    const types = AppModuleType.values;
    final currentIndex = types.indexOf(boxType);
    final nextIndex = (currentIndex + 1) % types.length;
    return types[nextIndex];
  }

  // copyWith
  Module copyWith({
    String? id,
    String? slug,
    String? name,
    String? description,
    ModuleStatus? status,
    ModuleVisibility? visibility,
    bool? defaultOnLanding,
    String? createdAt,
    String? updatedAt,
    AppModuleType? boxType,
    int? index,
  }) {
    return Module(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      defaultOnLanding: defaultOnLanding ?? this.defaultOnLanding,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      boxType: boxType ?? this.boxType,
      index: index ?? this.index,
    );
  }
}

Future<void> contentNotAvailablePopup(BuildContext context) async {
  final isMobile = DeviceHelper.isMobile(context);
  final theme = Theme.of(context);
  final locale = AppLocalizations.of(context);
  return await displayPopUp(
    context: context,
    okText: locale.common_ok,
    bgColor: const Color(0xFFE7E5DD),
    // okEnabled: quizLoaded,
    noActions: true,
    contents: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: AppRadius.tiny,
                ),
                padding: const EdgeInsets.all(4),
                child: SvgPicture.asset(
                  AppIcons.warningIconPath,
                  width: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                  height: isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight,
                ),
              ),
            ],
          ),
          AppSpacing.spacing8_Box,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.popup_contentNotAvailable_title,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.labelLarge,
                ),
                AppSpacing.spacing8_Box,
                Text(
                  locale.popup_contentNotAvailable_body,
                  textAlign: TextAlign.start,
                  style: theme.textTheme.bodyMedium!.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      AppSpacing.spacing40_Box,
      Align(
        alignment: Alignment.centerRight,
        child: AppXButton(
          text: locale.popup_contentNotAvailable_cta,
          shrinkWrap: true,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          isLoading: false,
        ),
      ),
    ],
  );
}

// ModuleBuilder.of(ctx).accountModule
class ModuleBuilder {
  final BuildContext context;
  late final AppLocalizations local;

  ModuleBuilder(this.context) {
    local = AppLocalizations.of(context);
  }

// Widget accountModule() {
//   return AppModuleWidget(
//     key: const ValueKey('module-account'),
//     boxType: AppModuleType.type2_2,
//     imagePath: AppImages.homeBox3Path,
//     title: local.landing_first_title,
//     subtitle: local.landing_first_subtitle,
//     button1Text: local.landing_first_button1,
//     button2Text: local.landing_first_button2,
//     button1OnPressed: () {
//       navigateToPath(context, to: AppRoutes.register);
//     },
//     button2OnPressed: () {
//       navigateToPath(context, to: AppRoutes.login);
//     },
//   );
// }
//
// Widget jobModule() {
//   return AppModuleWidget(
//     key: const ValueKey('module-job'),
//     boxType: AppModuleType.type2_1,
//     imagePath: AppImages.homeBox6Path,
//     title: local.landing_second_title,
//     subtitle: local.landing_second_subtitle,
//     button1Text: local.landing_second_button,
//     button1OnPressed: () {
//       navigateToPath(context, to: AppRoutes.jobModule);
//     },
//   );
// }
//
// Widget ressourcesModule() {
//   return AppModuleWidget(
//     key: const ValueKey('module-ressources'),
//     boxType: AppModuleType.type2_1,
//     imagePath: AppImages.homeBox4Path,
//     title: local.user_ressources_module_title,
//     subtitle: local.user_ressources_module_subtitle,
//     button1Text: local.user_ressources_module_button,
//     button1OnPressed: () {
//       navigateToPath(context, to: AppRoutes.userRessourcesModule);
//     },
//   );
// }
//
// Widget getById(String id) {
//   switch (slug) {
//     case 'account':
//       return accountModule();
//     case 'job':
//       return jobModule();
//     case 'ressources':
//       return ressourcesModule();
//     default:
//       return AppModuleWidget(
//         key: ValueKey('module-$id'),
//         title: '${FAKER.lorem.words(3).join(' ')} ${FAKER.lorem.words(2).join(' ')}',
//         subtitle: '${FAKER.lorem.sentence()} ${FAKER.lorem.sentence()}',
//         boxType: AppModuleType.type2_2,
//         imagePath: [
//           AppImages.homeBox1Path,
//           AppImages.homeBox2Path,
//           AppImages.homeBox3Path,
//           AppImages.homeBox4Path,
//           AppImages.homeBox5Path,
//           AppImages.homeBox6Path
//         ].getRandomElement()!,
//         button1Text: '${FAKER.lorem.word()} ${FAKER.lorem.word()} ${FAKER.lorem.word()}',
//         button1OnPressed: () {
//           navigateToPath(context, to: AppRoutes.profile);
//         },
//         // can be null
//         button2Text: FAKER.randomGenerator.boolean()
//             ? '${FAKER.lorem.word()} ${FAKER.lorem.word()} ${FAKER.lorem.word()}'
//             : null,
//         button2OnPressed: FAKER.randomGenerator.boolean()
//             ? () {
//                 navigateToPath(context, to: AppRoutes.landing);
//               }
//             : null,
//       );
//   }
// }

// Widget getBy(Module module) {
//   // final AppModuleWidget widget = getById(module.id) as AppModuleWidget;
//
//   return AppModuleWidget(
//     module: module,
//     // key: widget.key,
//     // title: widget.title,
//     // subtitle: widget.subtitle,
//     // boxType: module.boxType,
//     // imagePath: widget.imagePath,
//     // button1Text: widget.button1Text,
//     // button2Text: widget.button2Text,
//     // button1OnPressed: widget.button1OnPressed,
//     // button2OnPressed: widget.button2OnPressed,
//     onSizeChanged: () {
//       // print('Module ${module.id} size changed to $newSize');
//     },
//   );
// }
}
