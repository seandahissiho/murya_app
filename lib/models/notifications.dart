enum AppNotificationCategory {
  reservationAll,
  reservationRead,
  reservationUnread,
  // room,
  // user,
  // client,
  // provider,
  // crew,
  // profile,
}

extension AppNotificationCategoryExtension on AppNotificationCategory {
  String get name {
    switch (this) {
      case AppNotificationCategory.reservationAll:
        return "Tout";
      case AppNotificationCategory.reservationRead:
        return "Lu";
      case AppNotificationCategory.reservationUnread:
        return "Non-lu";
      // case AppNotificationCategory.room:
      //   return "Salle";
      // case AppNotificationCategory.user:
      //   return "Utilisateur";
      // case AppNotificationCategory.client:
      //   return "Client";
      // case AppNotificationCategory.provider:
      //   return "Prestataire";
      // case AppNotificationCategory.crew:
      //   return "Équipe";
      // case AppNotificationCategory.profile:
      //   return "Profile";
    }
  }

  String get value {
    switch (this) {
      case AppNotificationCategory.reservationAll:
      case AppNotificationCategory.reservationRead:
      case AppNotificationCategory.reservationUnread:
        return "RESERVATION";

      // case AppNotificationCategory.room:
      //   return "ROOM";
      // case AppNotificationCategory.user:
      //   return "USER";
      // case AppNotificationCategory.client:
      //   return "CLIENT";
      // case AppNotificationCategory.provider:
      //   return "PROVIDER";
      // case AppNotificationCategory.crew:
      //   return "CREW";
      // case AppNotificationCategory.profile:
      //   return "PROFILE";
    }
  }
}

enum AppNotificationStatus {
  read,
  unread,
}

extension AppNotificationStatusExtension on AppNotificationStatus {
  String get name {
    switch (this) {
      case AppNotificationStatus.read:
        return "Lu";
      case AppNotificationStatus.unread:
        return "Non-lu";
    }
  }

  String get value {
    switch (this) {
      case AppNotificationStatus.read:
        return "READ";
      case AppNotificationStatus.unread:
        return "UNREAD";
    }
  }
}

enum AppNotificationType {
  success,
  error,
  info,
  custom,
}

extension AppNotificationTypeExtension on AppNotificationType {
  String get name {
    switch (this) {
      case AppNotificationType.success:
        return "Succès";
      case AppNotificationType.error:
        return "Erreur";
      case AppNotificationType.info:
        return "Info";
      case AppNotificationType.custom:
        return "Custom";
    }
  }

  String get value {
    switch (this) {
      case AppNotificationType.success:
        return "SUCCES";
      case AppNotificationType.error:
        return "ERROR";
      case AppNotificationType.info:
        return "INFO";
      case AppNotificationType.custom:
        return "CUSTOM";
    }
  }
}

class AppNotification {
  final String? id;
  final String? userId;
  final String title;
  final String body;
  final String? imageUrl;
  final String? deeplink;
  final dynamic data;
  final List<AppNotificationAction> actions;
  final AppNotificationType type;
  final AppNotificationCategory? category;
  final AppNotificationStatus status;
  DateTime? createdAt;
  DateTime? readAt;

  AppNotification({
    this.id,
    this.userId,
    required this.title,
    required this.body,
    this.imageUrl,
    this.deeplink,
    this.actions = const [],
    this.type = AppNotificationType.info,
    this.status = AppNotificationStatus.unread,
    this.category,
    this.data,
    this.createdAt,
    this.readAt,
  }) {
    createdAt ??= DateTime.now();
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      userId: json['userId'],
      title: json['title'] ?? 'No title',
      body: json['body'] ?? 'No body',
      type: AppNotificationType.values.firstWhere((element) => element.value == json['type']),
      status: AppNotificationStatus.values.firstWhere((element) => element.value == json['status']),
      category: AppNotificationCategory.values.firstWhere((element) => element.value == json['category']),
      createdAt: DateTime.parse(json['createdAt']),
      data: json['data'],
    );
  }

  factory AppNotification.fromData(dynamic data) {
    String title = "Nouvelle notification";
    String body = "Vous avez une nouvelle notification.";
    DateTime createdAt = DateTime.now();
    DateTime readAt = DateTime.now();
    AppNotificationType type = AppNotificationType.info;
    if (data == null) {
      return AppNotification(title: title, body: body, createdAt: createdAt, readAt: readAt);
    }
    if (title == "Nouvelle notification" && body == "Vous avez une nouvelle notification.") {}
    return AppNotification(
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      readAt: null,
    );
  }

  String get postTreatmentBody {
    String body = this.body;
    return body.replaceAll('\\n', '\n');
  }

  AppNotification copyWith({
    String? title,
    String? body,
    String? imageUrl,
    String? deeplink,
    dynamic data,
    List<AppNotificationAction>? actions,
    AppNotificationType? type,
    DateTime? createdAt,
    DateTime? readAt,
    AppNotificationStatus? status,
  }) {
    return AppNotification(
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      deeplink: deeplink ?? this.deeplink,
      data: data ?? this.data,
      actions: actions ?? this.actions,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
    );
  }
}

class AppNotificationAction {
  final String title;
  final String? deeplink;

  AppNotificationAction({
    required this.title,
    this.deeplink,
  });
}
