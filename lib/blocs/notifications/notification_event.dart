part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class InitializeNotifications extends NotificationEvent {}

class NewNotificationEvent extends NotificationEvent {
  final AppNotification notification;

  NewNotificationEvent({required this.notification});
}

class ErrorNotificationEvent extends NotificationEvent {
  final String? message;
  final bool isImportant;

  ErrorNotificationEvent({
    required this.message,
    this.isImportant = false,
  });
}

class InfoNotificationEvent extends NotificationEvent {
  final String? message;
  final bool isImportant;

  InfoNotificationEvent({
    required this.message,
    this.isImportant = false,
  });
}

class SuccessNotificationEvent extends NotificationEvent {
  final String? message;
  final bool isImportant;

  SuccessNotificationEvent({
    required this.message,
    this.isImportant = false,
  });
}

class NewWebHookNotificationEvent extends NotificationEvent {
  final AppNotification notification;

  NewWebHookNotificationEvent({required this.notification});
}

class ChangeNotificationCategoryEvent extends NotificationEvent {
  final List<AppNotificationCategory> categories;

  ChangeNotificationCategoryEvent({required this.categories});
}

class ChangeNotificationPageEvent extends NotificationEvent {
  final int page;

  ChangeNotificationPageEvent({required this.page});
}

class SubscribeToNotificationsEvent extends NotificationEvent {
  final String userId;

  SubscribeToNotificationsEvent({required this.userId});
}

class ChangeNotificationReadStatusEvent extends NotificationEvent {
  final AppNotification notification;

  ChangeNotificationReadStatusEvent({required this.notification});
}
