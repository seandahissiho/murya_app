part of 'modules_bloc.dart';

@immutable
sealed class ModulesState {
  final List<Module> modules;

  const ModulesState({this.modules = const []});
}

final class ModulesInitial extends ModulesState {}

final class ModulesLoading extends ModulesState {
  const ModulesLoading({required super.modules});
}

final class ModulesLoaded extends ModulesState {
  const ModulesLoaded({required super.modules});
}
