import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/quest.dart';
import 'package:murya/repositories/profile.repository.dart';

part 'quests_event.dart';
part 'quests_state.dart';

class QuestsBloc extends Bloc<QuestsEvent, QuestsState> {
  final BuildContext context;
  late final ProfileRepository profileRepository;
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  QuestsBloc({required this.context}) : super(QuestsInitial()) {
    on<QuestsLoadLineageEvent>(_onQuestsLoadLineageEvent);

    profileRepository = RepositoryProvider.of<ProfileRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _authSubscription = authBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(QuestsLoadLineageEvent(scope: QuestScope.all));
      }
    });
  }

  FutureOr<void> _onQuestsLoadLineageEvent(QuestsLoadLineageEvent event, Emitter<QuestsState> emit) async {
    if (!authBloc.state.isAuthenticated) {
      return;
    }
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
      userJobId: event.userJobId,
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
    _authSubscription.cancel();
    return super.close();
  }
}
