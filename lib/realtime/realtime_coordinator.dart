import 'dart:async';

import 'package:flutter/material.dart';
import 'package:murya/blocs/authentication/authentication_bloc.dart';
import 'package:murya/blocs/modules/profile/profile_bloc.dart';
import 'package:murya/blocs/modules/resources/resources_bloc.dart';
import 'package:murya/blocs/notifications/notification_bloc.dart';
import 'package:murya/config/routes.dart';
import 'package:murya/helpers.dart';

import 'sse_event.dart';
import 'sse_service.dart';

class RealtimeCoordinator {
  RealtimeCoordinator({
    required BuildContext context,
    required SseService sseService,
    required AuthenticationBloc authenticationBloc,
    required ProfileBloc profileBloc,
    required ResourcesBloc resourcesBloc,
    required NotificationBloc notificationBloc,
  })  : _context = context,
        _sseService = sseService,
        _authenticationBloc = authenticationBloc,
        _profileBloc = profileBloc,
        _resourcesBloc = resourcesBloc,
        _notificationBloc = notificationBloc;

  final BuildContext _context;
  final SseService _sseService;
  final AuthenticationBloc _authenticationBloc;
  final ProfileBloc _profileBloc;
  final ResourcesBloc _resourcesBloc;
  final NotificationBloc _notificationBloc;

  StreamSubscription<AuthenticationState>? _authSubscription;
  StreamSubscription<SseEvent>? _sseSubscription;

  void start() {
    _authSubscription ??= _authenticationBloc.stream.listen(_onAuthState);
    _sseSubscription ??= _sseService.events.listen(_handleEvent);
    _onAuthState(_authenticationBloc.state);
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _sseSubscription?.cancel();
    await _sseService.disconnect();
  }

  void _onAuthState(AuthenticationState state) {
    if (state is Authenticated) {
      _sseService.connect();
      return;
    }
    if (state is Unauthenticated) {
      _sseService.disconnect();
    }
  }

  void _handleEvent(SseEvent event) {
    if (event.type != 'ping') {
      debugPrint('Realtime event: ${event.type}');
    }
    switch (event.type) {
      case 'progress.updated':
        final userId = event.data['userId'];
        if (userId is String && userId.isNotEmpty) {
          _profileBloc.add(ProfileLoadEvent(userId: userId, notifyIfNotFound: false));
        } else {
          _profileBloc.add(ProfileLoadEvent(notifyIfNotFound: false));
        }
        break;
      case 'content.available':
        _handleContentAvailable(event);
        break;
      case 'notification.created':
        final message = event.data['message'];
        _notificationBloc.add(InfoNotificationEvent(
          message: message is String && message.isNotEmpty ? message : 'Nouvelle notification.',
          isImportant: true,
        ));
        _notificationBloc.add(InitializeNotifications());
        break;
      case 'ready':
      case 'ping':
        break;
      default:
        debugPrint('Unhandled SSE event: ${event.type}');
        break;
    }
  }

  void _handleContentAvailable(SseEvent event) {
    final payload = event.data['payload'];
    if (payload is! Map<String, dynamic>) {
      debugPrint('content.available payload missing or invalid.');
      return;
    }
    final userJobId = payload['userJobId'];
    if (userJobId is String && userJobId.isNotEmpty) {
      _resourcesBloc.add(LoadResources(userJobId: userJobId));
    } else {
      _resourcesBloc.add(LoadResources());
    }

    final autoDisplay = payload['auto_display'];
    if (autoDisplay is bool && autoDisplay) {
      final resourceId = payload['resourceId'];
      if (resourceId is String && resourceId.isNotEmpty) {
        if (!_canNavigate()) {
          debugPrint('Skipping auto navigation: app not active or context unmounted.');
          return;
        }
        navigateToPath(
          _context,
          to: AppRoutes.userResourceViewerModule.replaceFirst(':id', resourceId),
        );
      }
    }
  }

  bool _canNavigate() {
    if (!_context.mounted) {
      return false;
    }
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == null) {
      return true;
    }
    return lifecycle == AppLifecycleState.resumed;
  }
}
