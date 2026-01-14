part of 'modules_bloc.dart';

@immutable
sealed class ModulesEvent {}

final class InitializeModules extends ModulesEvent {
  final BuildContext context;

  InitializeModules({required this.context});
}

final class LoadModules extends ModulesEvent {
  LoadModules();
}

final class LoadLandingModules extends ModulesEvent {
  final bool force;

  LoadLandingModules({this.force = false});
}

final class LoadCatalogModules extends ModulesEvent {
  final bool force;

  LoadCatalogModules({this.force = false});
}

final class LoadLandingAudit extends ModulesEvent {
  final DateTime? since;

  LoadLandingAudit({this.since});
}

final class UpdateModule extends ModulesEvent {
  final Module module;

  UpdateModule({required this.module});
}

class ReorderModules extends ModulesEvent {
  final int from;
  final int to;

  ReorderModules({required this.from, required this.to});
}

final class AddLandingModule extends ModulesEvent {
  final String moduleId;

  AddLandingModule({required this.moduleId});
}

final class RemoveLandingModule extends ModulesEvent {
  final String moduleId;

  RemoveLandingModule({required this.moduleId});
}

final class ResetModules extends ModulesEvent {
  ResetModules();
}
