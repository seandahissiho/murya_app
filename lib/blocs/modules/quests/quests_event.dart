part of 'quests_bloc.dart';

@immutable
sealed class QuestsEvent {}

final class QuestsLoadLineageEvent extends QuestsEvent {
  final QuestScope scope;
  final String? userJobId;
  final String? timezone;
  final bool notifyOnError;

  QuestsLoadLineageEvent({
    required this.scope,
    this.userJobId,
    this.timezone,
    this.notifyOnError = true,
  });
}
