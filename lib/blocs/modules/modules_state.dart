part of 'modules_bloc.dart';

@immutable
sealed class ModulesState {
  final List<Module> modules;
  final List<Module> catalogModules;
  final List<LandingEvent> auditEvents;
  final bool isLoading;
  final bool isCatalogLoading;
  final bool isAuditLoading;

  const ModulesState({
    this.modules = const [],
    this.catalogModules = const [],
    this.auditEvents = const [],
    this.isLoading = false,
    this.isCatalogLoading = false,
    this.isAuditLoading = false,
  });

  getModuleById(String s) {
    return modules.firstWhereOrNull((module) => module.id == s);
  }
}

final class ModulesInitial extends ModulesState {}

final class ModulesLoading extends ModulesState {
  const ModulesLoading({
    required super.modules,
    required super.catalogModules,
    required super.auditEvents,
    this.loading = true,
    this.catalogLoading = false,
    this.auditLoading = false,
  });

  final bool loading;
  final bool catalogLoading;
  final bool auditLoading;

  @override
  bool get isLoading => loading;

  @override
  bool get isCatalogLoading => catalogLoading;

  @override
  bool get isAuditLoading => auditLoading;
}

final class ModulesLoaded extends ModulesState {
  const ModulesLoaded({
    required super.modules,
    required super.catalogModules,
    required super.auditEvents,
    super.isLoading,
    super.isCatalogLoading,
    super.isAuditLoading,
  });
}
