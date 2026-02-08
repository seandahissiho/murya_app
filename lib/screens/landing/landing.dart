import 'dart:developer';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:murya/config/app_icons.dart';
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
    final locale = AppLocalizations.of(context);
    return [
      BeamPage(
        key: const ValueKey('landing-page'),
        title: locale.landing_browser_title,
        child: const LandingScreen(),
      ),
    ];
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    context.read<ModulesBloc>().add(LoadCatalogModules(force: true));
    context.read<ModulesBloc>().add(LoadLandingModules(force: true));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) =>
          previous.language.code != current.language.code || previous.newRoute != current.newRoute,
      listener: (context, state) {
        log('LandingScreen: Reloading modules for ${state.newRoute} (${state.language.code}).');
        if (!state.newRoute.startsWith(AppRoutes.landing)) return;
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
    Color(0xFF5F27CD),
    Color(0xFF9159E5),
    Color(0xFFC26BFF),
    Color(0xFFFF4100),
    Color(0xFF49B86C),
    Color(0xFF05E7D2),
    Color(0xFF8CD9E5),
    Color(0xFF3ED20D),
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = DeviceHelper.isMobile(context);
    final double ctaHeight = DeviceHelper.isMobile(context) ? mobileCTAHeight : tabletAndAboveCTAHeight;
    return Padding(
      padding: EdgeInsets.only(
        bottom: isMobile
            ? AppSpacing.pageMargin + MediaQuery.of(context).padding.bottom
            : AppSpacing.pageMargin + AppSpacing.spacing40,
      ),
      child: SizedBox(
        width: ctaHeight,
        height: ctaHeight,
        child: AppXButton(
          leftIconPath: AppIcons.plusIconPath,
          shrinkWrap: true,
          onPressed: () async {
            return await _openBottomSheet(context);
            return await contentNotAvailablePopup(context);
          },
          isLoading: false,
        ),
      ),
    );
  }

  Future<void> _openBottomSheet(BuildContext context) async {
    final AppSize screenSize = AppSize(context);
    await showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: math.min(screenSize.screenHeight * 0.51, 530),
        maxWidth: screenSize.screenWidth,
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) {
        return const _BottomSheetContent();
      },
    );
  }
}

class LandingCustomizationDialog extends StatelessWidget {
  const LandingCustomizationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = DeviceHelper.isMobile(context);
    final locale = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 560,
        padding: const EdgeInsets.all(AppSpacing.spacing24),
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
                      locale.landing_customize_title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.spacing16_Box,
                Text(
                  locale.landing_customize_description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                AppSpacing.spacing16_Box,
                Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadius20,
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: modules.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                          child: Text(
                            locale.modules_empty_state,
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
                AppSpacing.spacing16_Box,
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
                        text: locale.landing_add_module,
                        shrinkWrap: false,
                      ),
                    ),
                    AppSpacing.spacing8_Box,
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
                        text: locale.landing_view_audit,
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
    final locale = AppLocalizations.of(context);
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing8, vertical: AppSpacing.spacing4),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing12,
        vertical: AppSpacing.spacing12,
      ),
      decoration: BoxDecoration(
        color: AppColors.whiteSwatch,
        borderRadius: AppRadius.borderRadius20,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: AppColors.textTertiary),
          AppSpacing.spacing8_Box,
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
                  AppSpacing.spacing2_Box,
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
                locale.label_default,
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
              text: locale.action_remove,
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
    final locale = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 640,
        padding: const EdgeInsets.all(AppSpacing.spacing24),
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
                      locale.modules_catalog_title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.spacing16_Box,
                if (state.isCatalogLoading)
                  const Center(child: CircularProgressIndicator())
                else if (modules.isEmpty)
                  Text(
                    locale.modules_empty_state,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: modules.length,
                      separatorBuilder: (_, __) => AppSpacing.spacing4_Box,
                      itemBuilder: (context, index) {
                        final module = modules[index];
                        final bool alreadyAdded = landingIds.contains(module.id);
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.spacing12),
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
                                      AppSpacing.spacing2_Box,
                                      Text(
                                        module.description!,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ] else if (module.slug != null && module.slug!.isNotEmpty) ...[
                                      AppSpacing.spacing2_Box,
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
                                  margin: const EdgeInsets.only(right: AppSpacing.spacing8),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundColor,
                                    borderRadius: AppRadius.tiny,
                                    border: Border.all(color: AppColors.borderMedium),
                                  ),
                                  child: Text(
                                    locale.label_default,
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
                                text: alreadyAdded ? locale.status_added : locale.action_add,
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
    final locale = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Container(
        width: isMobile ? double.infinity : 560,
        padding: const EdgeInsets.all(AppSpacing.spacing24),
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
                      locale.landing_audit_title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary.shade900,
                          ),
                    ),
                    const AppXCloseButton(),
                  ],
                ),
                AppSpacing.spacing16_Box,
                if (state.isAuditLoading)
                  const Center(child: CircularProgressIndicator())
                else if (events.isEmpty)
                  Text(
                    locale.landing_audit_empty,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => AppSpacing.spacing4_Box,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final moduleName = _moduleNameForEvent(context, event, state.modules, state.catalogModules);
                        final actorLabel = event.actor == LandingActor.system
                            ? locale.landing_audit_actor_system
                            : locale.landing_audit_actor_user;
                        final actionLabel = event.action == LandingAction.remove
                            ? locale.landing_audit_action_removed
                            : locale.landing_audit_action_added;
                        final dateLabel = event.createdAt != null ? event.createdAt!.ddMMMyyyy() : '';
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.spacing12),
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
                              AppSpacing.spacing8_Box,
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
                                      AppSpacing.spacing2_Box,
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

class _BottomSheetContent extends StatefulWidget {
  const _BottomSheetContent({super.key});

  @override
  State<_BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  final Map<String, bool> _pressedModules = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = AppLocalizations.of(context);
    final AppSize screenSize = AppSize(context);
    final bool isMobile = DeviceHelper.isMobile(context);
    return BlocConsumer<ModulesBloc, ModulesState>(
      listener: (context, state) {
        setState(() {});
      },
      builder: (context, state) {
        final modules = state.catalogModules
            .whereOrEmpty(
              (module) => !state.modules.any((landingModule) => landingModule.id == module.id),
            )
            .toList();
        return ColoredBox(
          color: const Color(0xFFE7E5DD),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7E5DD),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.tinyRadius)),
                  ),
                  padding: EdgeInsets.only(
                    left: isMobile
                        ? mobileCTAHeight + AppSpacing.spacing16
                        : tabletAndAboveCTAHeight + AppSpacing.spacing16,
                    right: isMobile
                        ? mobileCTAHeight + AppSpacing.spacing16
                        : tabletAndAboveCTAHeight + AppSpacing.spacing16,
                    top: AppSpacing.spacing24,
                    bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spacing24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(mainAxisSize: MainAxisSize.max, children: []),
                      Text(
                        locale.landing_interactions_title,
                        style: GoogleFonts.anton(
                          color: AppColors.textPrimary,
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          height: 56 / 40,
                          letterSpacing: -0.02 * 40,
                        ),
                      ),
                      AppSpacing.spacing24_Box,
                      Expanded(
                        child: LayoutBuilder(builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: Wrap(
                                spacing: AppSpacing.spacing16,
                                runSpacing: AppSpacing.spacing16,
                                children: modules
                                    .map(
                                      (module) => InkWell(
                                        onTap: () {
                                          setState(() {
                                            _pressedModules[module.slug ?? ''] =
                                                !(_pressedModules[module.slug] == true);
                                          });
                                        },
                                        child: Container(
                                          height: constraints.maxHeight,
                                          width: constraints.maxHeight,
                                          decoration: BoxDecoration(
                                            color: AppButtonColors.secondarySurfaceDefault,
                                            borderRadius: AppRadius.tiny,
                                            border: Border.all(color: AppButtonColors.secondaryBorderDefault),
                                          ),
                                          padding: const EdgeInsets.all(AppSpacing.spacing24),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                module.title(context),
                                                textAlign: TextAlign.start,
                                                // font-family: Anton;
                                                // font-weight: 400;
                                                // font-style: Regular;
                                                // font-size: 32px;
                                                // leading-trim: NONE;
                                                // line-height: 38px;
                                                // letter-spacing: -2%;
                                                style: GoogleFonts.anton(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w400,
                                                  height: 38 / 32,
                                                  letterSpacing: -0.02 * 32,
                                                ),
                                              ),
                                              AppSpacing.spacing24_Box,
                                              Expanded(
                                                child: _pressedModules[module.slug] != true
                                                    ? _defaultModuleContent(module)
                                                    : _detailledModuleContent(module, locale, theme),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                indent: 0,
                endIndent: 0,
                color: AppColors.borderMedium,
                height: 0,
              ),
              Container(
                height:
                    (isMobile ? mobileCTAHeight : tabletAndAboveCTAHeight) + AppSpacing.spacing40 / (isMobile ? 2 : 1),
                width: double.infinity,
                color: const Color(0xFFE7E5DD),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24, vertical: AppSpacing.spacing16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppXCloseBottomSheetButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _defaultModuleContent(Module module) {
    bool isSvg = module.defaultImagePath.toLowerCase().endsWith('.svg');
    if (!isSvg) {
      return Image.asset(
        module.defaultImagePath ?? '',
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 48, color: AppColors.textSecondary),
        ),
      );
    }
    return SvgPicture.asset(
      module.defaultImagePath,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.contain,
    );
  }

  _detailledModuleContent(Module module, AppLocalizations locale, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.description ?? '',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.spacing24_Box,
        AppXButton(
          onPressed: () async {
            return await contentNotAvailablePopup(context);
          },
          isLoading: false,
          shrinkWrap: false,
          text: locale.action_add,
        )
      ],
    );
  }
}
