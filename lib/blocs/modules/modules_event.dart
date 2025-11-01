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

final class UpdateModule extends ModulesEvent {
  final Module module;

  UpdateModule({required this.module});
}

class ReorderModules extends ModulesEvent {
  final int from;
  final int to;

  ReorderModules({required this.from, required this.to});
}
