import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/models/app_user.dart';
import 'package:murya/repositories/profile.repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final BuildContext context;
  User _userProfile = User.empty();
  late final ProfileRepository profileRepository;
  late final NotificationBloc notificationBloc;
  late final AuthenticationBloc authBloc;
  late final StreamSubscription<AuthenticationState> _authSubscription;

  User get user => _userProfile;

  ProfileBloc({required this.context}) : super(ProfileInitial()) {
    on<ProfileEvent>((event, emit) {
      emit(ProfileLoading(
        user: state.user,
      ));
    });
    on<ProfileLoadEvent>(_onProfileLoadEvent);

    profileRepository = RepositoryProvider.of<ProfileRepository>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    authBloc = BlocProvider.of<AuthenticationBloc>(context);
    _authSubscription = authBloc.stream.listen((state) {
      if (state is Authenticated) {
        add(ProfileLoadEvent());
      }
    });
  }

  FutureOr<void> _onProfileLoadEvent(ProfileLoadEvent event, Emitter<ProfileState> emit) async {
    final result = await profileRepository.getMe();
    if (result.isError) {
      notificationBloc.add(ErrorNotificationEvent(
        message: result.error,
      ));
      authBloc.add(SignOutEvent());
      return;
    }
    _userProfile = result.data!;
    emit(ProfileLoaded(user: _userProfile));
  }
}
