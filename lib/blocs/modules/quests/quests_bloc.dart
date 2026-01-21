import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/modules/jobs/jobs_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/repositories/profile.repository.dart';

part 'quests_event.dart';
part 'quests_state.dart';

class QuestsBloc extends Bloc<QuestsEvent, QuestsState> {
  final BuildContext context;
  late final ProfileRepository profileRepository;
  late final NotificationBloc notificationBloc;
  late final JobBloc jobBloc;
  late final StreamSubscription<JobState> _jobSubscription;

  QuestsBloc({required this.context}) : super(QuestsInitial()) {
    on<QuestsLoadLineageEvent>(_onQuestsLoadLineageEvent);

    profileRepository = RepositoryProvider.of<ProfileRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    jobBloc = BlocProvider.of<JobBloc>(context);
    _jobSubscription = jobBloc.stream.listen((state) {
      if (state is UserJobDetailsLoaded) {
        add(QuestsLoadLineageEvent(scope: QuestScope.all));
      }
    });
  }

  FutureOr<void> _onQuestsLoadLineageEvent(QuestsLoadLineageEvent event, Emitter<QuestsState> emit) async {
    emit(QuestsLoading(
      questLineage: state.questLineage,
      questLineageLoading: true,
      questLineageError: null,
      questLineageUserJobId: event.userJobId,
      questLineageTimezone: event.timezone,
      questLineageScope: event.scope,
    ));

    final result = await profileRepository.getQuestLineage(
      scope: event.scope,
      timezone: event.timezone,
      userJobId: event.userJobId ?? jobBloc.state.userCurrentJob?.id,
    );

    if (result.isError) {
      if (event.notifyOnError) {
        notificationBloc.add(ErrorNotificationEvent(message: result.error));
      }
      emit(QuestsLoaded(
        questLineage: state.questLineage,
        questLineageLoading: false,
        questLineageError: result.error,
        questLineageUserJobId: event.userJobId,
        questLineageTimezone: event.timezone,
        questLineageScope: event.scope,
      ));
      return;
    }

    emit(QuestsLoaded(
      questLineage: result.data ?? const QuestLineage(),
      questLineageLoading: false,
      questLineageError: null,
      questLineageUserJobId: event.userJobId,
      questLineageTimezone: event.timezone,
      questLineageScope: event.scope,
    ));
  }

  @override
  Future<void> close() {
    _jobSubscription.cancel();
    return super.close();
  }

  double getUserQuestMapCompletionPercentage() {
    if (state.questLineage.userQuestMapTotalItems == 0) {
      return 0;
    }
    final result = (state.questLineage.userQuestMapCompletedItems / state.questLineage.userQuestMapTotalItems) * 100;
    return result;
  }
}
