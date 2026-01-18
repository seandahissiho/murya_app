part of 'quests_bloc.dart';

@immutable
sealed class QuestsState {
  final QuestLineage questLineage;
  final bool questLineageLoading;
  final String? questLineageError;
  final String? questLineageUserJobId;
  final String? questLineageTimezone;
  final QuestScope? questLineageScope;

  const QuestsState({
    this.questLineage = const QuestLineage(),
    this.questLineageLoading = false,
    this.questLineageError,
    this.questLineageUserJobId,
    this.questLineageTimezone,
    this.questLineageScope,
  });

  @override
  String toString() => 'QuestsState(questLineageLoading: $questLineageLoading)';
}

final class QuestsInitial extends QuestsState {}

final class QuestsLoading extends QuestsState {
  const QuestsLoading({
    required super.questLineage,
    super.questLineageLoading,
    super.questLineageError,
    super.questLineageUserJobId,
    super.questLineageTimezone,
    super.questLineageScope,
  });
}

final class QuestsLoaded extends QuestsState {
  const QuestsLoaded({
    required super.questLineage,
    super.questLineageLoading,
    super.questLineageError,
    super.questLineageUserJobId,
    super.questLineageTimezone,
    super.questLineageScope,
  });
}
