import 'package:flutter/cupertino.dart';
import 'package:murya/components/app_module.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/main.dart';

enum AppModuleType {
  type1,
  type1_2,
  // type1_3,
  type2_1,
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
  final String id;
  final AppModuleType boxType;

  // final Pair<int, int> topLeftPosition;
  final int index;

  Module({
    required this.id,
    this.boxType = AppModuleType.type2_2,
    required this.index,
  });

  // fromJson
  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      boxType: AppModuleType.values.firstWhere(
        (e) => e.name == json['boxType'],
        orElse: () => AppModuleType.type2_2,
      ),
      index: json['index'],
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'boxType': boxType.name,
      'index': index,
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
    AppModuleType? boxType,
    int? index,
  }) {
    return Module(
      id: id ?? this.id,
      boxType: boxType ?? this.boxType,
      index: index ?? this.index,
    );
  }
}

// ModuleBuilder.of(ctx).accountModule
class ModuleBuilder {
  final BuildContext context;
  late final AppLocalizations local;

  ModuleBuilder(this.context) {
    local = AppLocalizations.of(context);
  }

  Widget accountModule() {
    return AppModuleWidget(
      boxType: AppModuleType.type2_2,
      imagePath: AppImages.homeBox3Path,
      title: local.landing_first_title,
      subtitle: local.landing_first_subtitle,
      button1Text: local.landing_first_button1,
      button2Text: local.landing_first_button2,
      button1OnPressed: () {
        navigateToPath(context, to: AppRoutes.register);
      },
      button2OnPressed: () {
        navigateToPath(context, to: AppRoutes.login);
      },
    );
  }

  Widget searchModule() {
    return AppModuleWidget(
      boxType: AppModuleType.type2_1,
      imagePath: AppImages.homeBox6Path,
      title: local.landing_second_title,
      subtitle: local.landing_second_subtitle,
      button1Text: local.landing_second_button,
      button1OnPressed: () {
        navigateToPath(context, to: AppRoutes.searchModule);
      },
    );
  }

  Widget statsModule() {
    return AppModuleWidget(
      boxType: AppModuleType.type2_1,
      imagePath: AppImages.homeBox4Path,
      title: local.user_stats_module_title,
      subtitle: local.user_stats_module_subtitle,
      button1Text: local.user_stats_module_button,
      button1OnPressed: () {
        navigateToPath(context, to: AppRoutes.userStatsModule);
      },
    );
  }

  Widget getById(String id) {
    switch (id) {
      case 'account':
        return accountModule();
      case 'search':
        return searchModule();
      case 'stats':
        return statsModule();
      default:
        return AppModuleWidget(
          key: ValueKey('module-$id'),
          title: '${FAKER.lorem.words(3).join(' ')} ${FAKER.lorem.words(2).join(' ')}',
          subtitle: '${FAKER.lorem.sentence()} ${FAKER.lorem.sentence()}',
          boxType: AppModuleType.type2_2,
          imagePath: [
            AppImages.homeBox1Path,
            AppImages.homeBox2Path,
            AppImages.homeBox3Path,
            AppImages.homeBox4Path,
            AppImages.homeBox5Path,
            AppImages.homeBox6Path
          ].getRandomElement()!,
          button1Text: '${FAKER.lorem.word()} ${FAKER.lorem.word()} ${FAKER.lorem.word()}',
          button1OnPressed: () {
            navigateToPath(context, to: AppRoutes.profile);
          },
          // can be null
          button2Text: FAKER.randomGenerator.boolean()
              ? '${FAKER.lorem.word()} ${FAKER.lorem.word()} ${FAKER.lorem.word()}'
              : null,
          button2OnPressed: FAKER.randomGenerator.boolean()
              ? () {
                  navigateToPath(context, to: AppRoutes.home);
                }
              : null,
        );
    }
  }

  Widget getBy(Module module) {
    final AppModuleWidget widget = getById(module.id) as AppModuleWidget;

    return AppModuleWidget(
      key: widget.key,
      title: widget.title,
      subtitle: widget.subtitle,
      boxType: module.boxType,
      imagePath: widget.imagePath,
      // imagePath: [
      //   AppImages.homeBox1Path,
      //   AppImages.homeBox2Path,
      //   AppImages.homeBox3Path,
      //   AppImages.homeBox4Path,
      //   AppImages.homeBox5Path,
      //   AppImages.homeBox6Path
      // ].elementAt(module.index % 6),
      button1Text: widget.button1Text,
      button2Text: widget.button2Text,
      button1OnPressed: widget.button1OnPressed,
      button2OnPressed: widget.button2OnPressed,
    );
  }
}
