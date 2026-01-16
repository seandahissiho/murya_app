import 'dart:developer';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/app/app_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/modules/modules_bloc.dart';
import 'package:murya/components/app_button.dart';
import 'package:murya/components/app_footer.dart';
import 'package:murya/components/modules/account_module.dart';
import 'package:murya/components/modules/app_module.dart';
import 'package:murya/components/modules/job_module.dart';
import 'package:murya/components/modules/ressources_module.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/l10n/l10n.dart';
import 'package:murya/models/landing_module.dart';
import 'package:murya/models/module.dart';
import 'package:murya/screens/app_bar/app_bar.dart';
import 'package:murya/screens/base.dart';

part '_landing_mobile.dart';
part '_landing_tablet+.dart';

class LandingLocation extends BeamLocation<RouteInformationSerializable<dynamic>> {
  @override
  List<String> get pathPatterns => [AppRoutes.landing];

  @override
  List<BeamPage> buildPages(BuildContext context, RouteInformationSerializable state) {
    final languageCode = context.read<AppBloc>().appLanguage.code;
    return [
      const BeamPage(
        key: ValueKey('landing-page'),
        title: 'Landing Page',
        child: LandingScreen(),
      ),
    ];
  }
}

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.language.code != current.language.code,
      listener: (context, state) {
        if (!state.newRoute.startsWith(AppRoutes.landing)) return;
        context.read<ModulesBloc>().add(LoadCatalogModules(force: true));
        context.read<ModulesBloc>().add(LoadLandingModules(force: true));
      },
      child: const BaseScreen(
        mobileScreen: MobileLandingScreen(),
        tabletScreen: TabletLandingScreen(),
        desktopScreen: TabletLandingScreen(),
      ),
    );
  }
}

class AddModuleButton extends StatelessWidget {
  const AddModuleButton({super.key});

  static const _colors = [
    // #5F27CD
    Color(0xFF5F27CD),
    // #9159E5
    Color(0xFF9159E5),
    // #C26BFF
    Color(0xFFC26BFF),
    // #FF4100
    Color(0xFFFF4100),
    // #49B86C
    Color(0xFF49B86C),
    // #05E7D2
    Color(0xFF05E7D2),
    // #8CD9E5
    Color(0xFF8CD9E5),
    // #3ED20D
    Color(0xFF3ED20D),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = DeviceHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile
            ? AppSpacing.pageMargin + MediaQuery.of(context).padding.bottom
            : AppSpacing.pageMargin + AppSpacing.sectionMargin,
      ),
      child: AppXButton(
        height: tabletAndAboveCTAHeight,
        leftIcon: const Icon(
          Icons.add,
          color: AppColors.textInverted,
        ),
        shrinkWrap: true,
        onPressed: () {},
        isLoading: false,
      ),
      // child: Blob.animatedRandom(
      //   size: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 27,
      //   edgesCount: 8,
      //   minGrowth: 3,
      //   duration: const Duration(milliseconds: 1000),
      //   loop: true,
      //   styles: BlobStyles(
      //     // color: Colors.red,
      //     gradient: const LinearGradient(
      //       colors: _colors,
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //     ).createShader(const Rect.fromLTRB(0, 0, 85, 85)),
      //     fillType: BlobFillType.fill,
      //     strokeWidth: 3,
      //   ),
      //   child: Center(
      //     child: MouseRegion(
      //       cursor: SystemMouseCursors.click,
      //       child: InkWell(
      //         onTap: () {
      //           showDialog(
      //             context: context,
      //             barrierDismissible: true,
      //             builder: (_) => const LandingCustomizationDialog(),
      //           );
      //         },
      //         child: Container(
      //           width: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 10,
      //           height: (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + 10,
      //           margin: const EdgeInsets.only(top: 10, left: 10),
      //           decoration: const BoxDecoration(
      //             shape: BoxShape.circle,
      //             gradient: LinearGradient(
      //               colors: _colors,
      //               begin: Alignment.topLeft,
      //               end: Alignment.bottomRight,
      //             ),
      //           ),
      //           padding: const EdgeInsets.all(2),
      //           child: Container(
      //             decoration: const BoxDecoration(
      //               shape: BoxShape.circle,
      //               color: Colors.black,
      //             ),
      //             child: const Icon(
      //               Icons.add,
      //               color: AppColors.textInverted,
      //               size: 32,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}

class LandingCustomizationDialog extends StatelessWidget {
  const LandingCustomizationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = DeviceHelper.isMobile(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 560,
        padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
        decoration: BoxDecoration(
          color: AppColors.whiteSwatch,
          borderRadius: AppRadius.medium,
        ),
        child: BlocBuilder<ModulesBloc, ModulesState>(
          builder: (context, state) {
            final modules = state.modules;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Personnaliser la landing',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.groupMarginBox,
                Text(
                  'Organisez vos modules, ajoutez-en de nouveaux, ou retirez ceux qui ne sont pas obligatoires.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                AppSpacing.groupMarginBox,
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadius20,
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: modules.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
                          child: Text(
                            'Aucun module disponible.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ReorderableListView.builder(
                          shrinkWrap: true,
                          itemCount: modules.length,
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;
                            context.read<ModulesBloc>().add(ReorderModules(from: oldIndex, to: newIndex));
                          },
                          itemBuilder: (context, index) {
                            final module = modules[index];
                            return _LandingModuleRow(
                              key: ValueKey('landing-module-${module.id}'),
                              module: module,
                            );
                          },
                        ),
                ),
                AppSpacing.groupMarginBox,
                Row(
                  children: [
                    Expanded(
                      child: AppXButton(
                        onPressed: () {
                          context.read<ModulesBloc>().add(LoadCatalogModules());
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const ModuleCatalogDialog(),
                          );
                        },
                        isLoading: false,
                        text: 'Ajouter un module',
                        shrinkWrap: false,
                      ),
                    ),
                    AppSpacing.elementMarginBox,
                    Expanded(
                      child: AppXButton(
                        onPressed: () {
                          context.read<ModulesBloc>().add(LoadLandingAudit());
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const LandingAuditDialog(),
                          );
                        },
                        isLoading: false,
                        text: "Voir l'audit",
                        shrinkWrap: false,
                        bgColor: AppColors.whiteSwatch,
                        borderColor: AppColors.primary.shade200,
                        fgColor: AppColors.primary.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LandingModuleRow extends StatelessWidget {
  final Module module;

  const _LandingModuleRow({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final bool isDefault = module.defaultOnLanding == true;
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.elementMargin, vertical: AppSpacing.tinyMargin),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerInsideMarginSmall,
        vertical: AppSpacing.containerInsideMarginSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteSwatch,
        borderRadius: AppRadius.borderRadius20,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: AppColors.textTertiary),
          AppSpacing.elementMarginBox,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (module.subtitle(context).isNotEmpty) ...[
                  AppSpacing.tinyTinyMarginBox,
                  Text(
                    module.subtitle(context),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: AppRadius.tiny,
                border: Border.all(color: AppColors.borderMedium),
              ),
              child: Text(
                'Default',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            )
          else
            AppXButton(
              onPressed: () {
                context.read<ModulesBloc>().add(RemoveLandingModule(moduleId: module.id ?? ''));
              },
              isLoading: false,
              text: 'Supprimer',
              shrinkWrap: true,
              bgColor: AppColors.whiteSwatch,
              borderColor: AppColors.borderMedium,
              fgColor: AppColors.textSecondary,
              height: 34,
            ),
        ],
      ),
    );
  }
}

class ModuleCatalogDialog extends StatelessWidget {
  const ModuleCatalogDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = DeviceHelper.isMobile(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 640,
        padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
        decoration: BoxDecoration(
          color: AppColors.whiteSwatch,
          borderRadius: AppRadius.medium,
        ),
        child: BlocBuilder<ModulesBloc, ModulesState>(
          builder: (context, state) {
            final modules = state.catalogModules;
            final landingIds = state.modules.map((module) => module.id).whereType<String>().toSet();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catalogue des modules',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.groupMarginBox,
                if (state.isCatalogLoading)
                  const Center(child: CircularProgressIndicator())
                else if (modules.isEmpty)
                  Text(
                    'Aucun module disponible.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: modules.length,
                      separatorBuilder: (_, __) => AppSpacing.tinyMarginBox,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final bool alreadyAdded = landingIds.contains(module.id);
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.borderRadius20,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      module.title(context),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (module.description != null && module.description!.isNotEmpty) ...[
                                      AppSpacing.tinyTinyMarginBox,
                                      Text(
                                        module.description!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ] else if (module.slug != null && module.slug!.isNotEmpty) ...[
                                      AppSpacing.tinyTinyMarginBox,
                                      Text(
                                        module.slug!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (module.defaultOnLanding == true)
                                Container(
                                  margin: const EdgeInsets.only(right: AppSpacing.elementMargin),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: AppRadius.tiny,
                                    border: Border.all(color: AppColors.borderMedium),
                                  ),
                                  child: Text(
                                    'Default',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                              AppXButton(
                                onPressed: alreadyAdded
                                    ? null
                                    : () {
                                        context.read<ModulesBloc>().add(AddLandingModule(moduleId: module.id ?? ''));
                                      },
                                isLoading: false,
                                text: alreadyAdded ? 'Ajoute' : 'Ajouter',
                                shrinkWrap: true,
                                disabled: alreadyAdded,
                                height: 34,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LandingAuditDialog extends StatelessWidget {
  const LandingAuditDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = DeviceHelper.isMobile(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 560,
        padding: const EdgeInsets.all(AppSpacing.containerInsideMargin),
        decoration: BoxDecoration(
          color: AppColors.whiteSwatch,
          borderRadius: AppRadius.medium,
        ),
        child: BlocBuilder<ModulesBloc, ModulesState>(
          builder: (context, state) {
            final events = state.auditEvents;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Historique',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.groupMarginBox,
                if (state.isAuditLoading)
                  const Center(child: CircularProgressIndicator())
                else if (events.isEmpty)
                  Text(
                    'Aucune action enregistree.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => AppSpacing.tinyMarginBox,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final moduleName = _moduleNameForEvent(context, event, state.modules, state.catalogModules);
                        final actorLabel = event.actor == LandingActor.system ? 'SYSTEM' : 'USER';
                        final actionLabel = event.action == LandingAction.remove ? 'a retire' : 'a ajoute';
                        final dateLabel = event.createdAt != null ? event.createdAt!.ddMMMyyyy() : '';
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.containerInsideMarginSmall),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.borderRadius20,
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                event.action == LandingAction.remove
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                color: event.action == LandingAction.remove
                                    ? AppColors.errorDefault
                                    : AppStatusColors.normal,
                              ),
                              AppSpacing.elementMarginBox,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$actorLabel $actionLabel $moduleName',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (dateLabel.isNotEmpty) ...[
                                      AppSpacing.tinyTinyMarginBox,
                                      Text(
                                        dateLabel,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _moduleNameForEvent(BuildContext context, LandingEvent event, List<Module> landing, List<Module> catalog) {
    final fromLanding = landing.firstWhereOrNull((module) => module.id == event.moduleId);
    if (fromLanding != null) return fromLanding.title(context);
    final fromCatalog = catalog.firstWhereOrNull((module) => module.id == event.moduleId);
    if (fromCatalog != null) return fromCatalog.title(context);
    return event.moduleId;
  }
}
