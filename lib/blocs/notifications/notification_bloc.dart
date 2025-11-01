import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:murya/config/DS.dart';
import 'package:murya/config/app_icons.dart';
import 'package:murya/config/custom_classes.dart';
import 'package:murya/models/notifications.dart';
import 'package:murya/repositories/notifications.repository.dart';
import 'package:sizer/sizer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class AppNotificationAction {
  final String title;
  final String? deeplink;

  AppNotificationAction({
    required this.title,
    this.deeplink,
  });
}

// Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//   // log('Handling a background message ${message.messageId}');
// }

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();
  final _statusController = StreamController<bool>.broadcast();
  bool _isConnected = false;
  int _reconnectAttempt = 0;

  WebSocketService() {
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    int retryCount = 0;
    _channel = WebSocketChannel.connect(
      Uri.parse(dotenv.env["SOCKET_URL"]!),
    );
    _channel!.ready.then((value) {
      _isConnected = true;
      _reconnectAttempt = 0;
      _statusController.add(true);
    });

    _channel!.stream.listen(
      (message) {
        _controller.add(message);
      },
      onDone: () {
        _isConnected = false;
        _statusController.add(false);
        _reconnect();
      },
      onError: (error) {
        _isConnected = false;
        _statusController.add(false);
        if (retryCount < 2) {
          retryCount++;
          // log('WebSocket error: $error. Retrying connection... ($retryCount)');
          _reconnect();
        }
      },
    );
  }

  void _reconnect() {
    if (_reconnectAttempt >= 2) {
      // Maximum attempts reached
      log('Max reconnection attempts reached.');
      return;
    }

    final delay = Duration(seconds: math.pow(2, _reconnectAttempt).toInt());
    _reconnectAttempt++;

    // log('Attempting to reconnect in ${delay.inSeconds} seconds...');

    Future.delayed(delay, () {
      if (!_isConnected) {
        _connectToWebSocket();
      }
    });
  }

  void sendMessage(dynamic data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(data);
    } else {
      log('WebSocket is not connected. Message not sent.');
    }
  }

  Stream<dynamic> get stream => _controller.stream;

  Stream<bool> get connectionStatus => _statusController.stream;

  void dispose() {
    _channel?.sink.close();
    _controller.close();
    _statusController.close();
  }
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  BuildContext? context;
  OverlayState? overlay;
  late final NotificationRepository notificationRepository;
  late WebSocketService _webSocketService;

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // String? _token;
  StreamManager<List<AppNotification>> notificationStream = StreamManager();

  List<AppNotification> notifications = [];
  List<AppNotificationCategory> categories = [];
  int page = 1;
  int totalPages = 0;
  int unreadCount = 0;

  NotificationBloc({required BuildContext this.context}) : super(NotificationInitial()) {
    on<NotificationEvent>((event, emit) {
      emit(NotificationsLoading(
        notificationStream: state.notificationStream,
        notifications: state.notifications,
        categories: state.categories,
        page: state.page,
        totalPages: state.totalPages,
        unreadCount: state.unreadCount,
      ));
    });
    on<InitializeNotifications>(_onInitializeNotifications);
    on<NewNotificationEvent>(_onNewNotificationEvent);
    on<ErrorNotificationEvent>(_onErrorNotificationEvent);
    on<InfoNotificationEvent>(_onInfoNotificationEvent);
    on<SuccessNotificationEvent>(_onSuccessNotificationEvent);
    on<NewWebHookNotificationEvent>(_onNewWebHookNotificationEvent);
    on<ChangeNotificationCategoryEvent>(_onChangeNotificationCategoryEvent);
    on<ChangeNotificationPageEvent>(_onChangeNotificationPageEvent);
    on<SubscribeToNotificationsEvent>(_onSubscribeToNotificationsEvent);
    on<ChangeNotificationReadStatusEvent>(_onChangeNotificationReadStatusEvent);

    notificationRepository = RepositoryProvider.of<NotificationRepository>(context!);
    _webSocketService = WebSocketService();

    _webSocketService.stream.listen(
      (message) {
        final decodedMessage = jsonDecode(message as String);
        // log('Received notification:');

        _webSocketService.sendMessage(jsonEncode({
          'type': 'message',
          'content': "Message received",
        }));

        if (decodedMessage["type"] == "notification") {
          final notification = AppNotification.fromJson(Map<String, dynamic>.from(decodedMessage["data"]));

          add(InfoNotificationEvent(message: notification.postTreatmentBody, isImportant: true));

          add(NewWebHookNotificationEvent(notification: notification));

          _acknowledgeNotification(notification);
        }
      },
      onError: (error) {
        // log('WebSocket error: $error');
      },
      onDone: () {
        // No need to handle reconnection here; it's managed by WebSocketService
        // log('WebSocket connection closed.');
      },
    );

    // _webSocketService.connectionStatus.listen((isConnected) {});
  }

  Future<void> _onInitializeNotifications(InitializeNotifications event, Emitter<NotificationState> emit) async {
    // await Firebase.initializeApp(
    //   // options: DefaultFirebaseOptions.currentPlatform,
    // );

    page = 1;
    totalPages = 0;
    unreadCount = 0;

    final getResult = await notificationRepository.getNotifications(
      selectedCategories: categories,
      page: page,
    );

    if (getResult.isError) {
      AppNotification notification = AppNotification(
        title: 'Erreur',
        body: getResult.error ?? 'Erreur inconnue',
        type: AppNotificationType.error,
      );
      emit(NewNotificationState(
        notification: notification,
        notificationStream: notificationStream,
        isImportant: false,
        notifications: notifications,
        page: page,
        totalPages: totalPages,
        unreadCount: unreadCount,
        context: context!,
        overlay: overlay,
      ));
    }

    notifications.clear();
    notifications.addAll(getResult.data!.$1);
    totalPages = getResult.data!.$2;
    unreadCount = getResult.data!.$3;
    notificationStream.addResponse(notifications);

    emit(NotificationInitialized(
      notificationStream: notificationStream,
      notifications: notifications,
      categories: categories,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
    ));
  }

  // Future<void> _handleForegroundMessage(RemoteMessage message) async {
  //   log('Got a message whilst in the foreground!');
  //
  //   if (message.notification != null) {
  //     log('Message also contained a notification: ${message.notification}');
  //     log(message.notification?.title ?? 'No title', name: "Title");
  //     log(message.notification?.body ?? 'No body', name: "Body");
  //     notifications.add(
  //       AppNotification.fromData(message),
  //     );
  //     notificationStream.addResponse(notifications);
  //
  //     add(NewNotificationEvent(
  //       notification: AppNotification.fromData(
  //         message,
  //       ),
  //     ));
  //   }
  // }

  // Future<void> requestNotificationPermission() async {
  //   NotificationSettings settings = await _firebaseMessaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //
  //   log('User granted permission: ${settings.authorizationStatus}');
  // }

  // Future<String?> getDeviceToken() async {
  //   String? deviceToken;
  //   try {
  //     deviceToken = await _firebaseMessaging.getToken(
  //         vapidKey:
  //             "BPeR1zNisoYM7RkV9IAVNpKpTRAoopD3FhiTxaVt687pXcJH-okf8Dhb36AIC-GcoEtAxO_jQmZ9FtCHbZuoEN8");
  //     assert(deviceToken != null);
  //   } catch (e) {
  //     await requestNotificationPermission();
  //     deviceToken = await _firebaseMessaging.getToken(
  //         vapidKey:
  //             "BPeR1zNisoYM7RkV9IAVNpKpTRAoopD3FhiTxaVt687pXcJH-okf8Dhb36AIC-GcoEtAxO_jQmZ9FtCHbZuoEN8");
  //   }
  //   return deviceToken;
  // }

  @override
  Future<void> close() {
    _webSocketService.dispose();
    notificationStream.dispose();
    return super.close();
  }

  Future<void> _onNewNotificationEvent(NewNotificationEvent event, Emitter<NotificationState> emit) async {
    emit(NewNotificationState(
      notification: event.notification,
      notificationStream: notificationStream,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
      context: context!,
      overlay: overlay,
    ));
  }

  FutureOr<void> _onErrorNotificationEvent(ErrorNotificationEvent event, Emitter<NotificationState> emit) {
    AppNotification notification = AppNotification(
      title: 'Erreur',
      body: event.message ?? 'Erreur inconnue',
      type: AppNotificationType.error,
    );
    emit(NewNotificationState(
      notification: notification,
      notificationStream: notificationStream,
      isImportant: event.isImportant,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
      context: context!,
      overlay: overlay,
    ));
  }

  FutureOr<void> _onInfoNotificationEvent(InfoNotificationEvent event, Emitter<NotificationState> emit) {
    AppNotification notification = AppNotification(
      title: 'Information',
      body: event.message ?? 'Une information importante vous concerne.',
      type: AppNotificationType.info,
    );
    emit(NewNotificationState(
      notification: notification,
      notificationStream: notificationStream,
      isImportant: event.isImportant,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
      context: context!,
      overlay: overlay,
    ));
  }

  FutureOr<void> _onSuccessNotificationEvent(SuccessNotificationEvent event, Emitter<NotificationState> emit) {
    AppNotification notification = AppNotification(
      title: 'Succès',
      body: event.message ?? 'Votre action a été effectuée avec succès.',
      type: AppNotificationType.success,
    );
    emit(NewNotificationState(
      notification: notification,
      notificationStream: notificationStream,
      isImportant: event.isImportant,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
      context: context!,
      overlay: overlay,
    ));
  }

  FutureOr<void> _onNewWebHookNotificationEvent(
      NewWebHookNotificationEvent event, Emitter<NotificationState> emit) async {
    page = 1;
    totalPages = 0;

    final getResult = await notificationRepository.getNotifications(
      selectedCategories: categories,
      page: page,
    );

    if (getResult.error != null || getResult.data == null) {
      AppNotification notification = AppNotification(
        title: 'Erreur',
        body: getResult.error ?? 'Erreur inconnue',
        type: AppNotificationType.error,
      );
      emit(NewNotificationState(
        notification: notification,
        notificationStream: notificationStream,
        isImportant: false,
        notifications: notifications,
        page: page,
        totalPages: totalPages,
        unreadCount: unreadCount,
        context: context!,
        overlay: overlay,
      ));
    }

    notifications.clear();
    notifications.addAll(getResult.data!.$1);
    totalPages = getResult.data!.$2;
    unreadCount = getResult.data!.$3;
    notificationStream.addResponse(notifications);

    emit(NewWebHookNotificationState(
      notificationStream: notificationStream,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onChangeNotificationCategoryEvent(
      ChangeNotificationCategoryEvent event, Emitter<NotificationState> emit) async {
    categories = event.categories;
    page = 1;
    totalPages = 0;

    final getResult = await notificationRepository.getNotifications(
      selectedCategories: categories,
      page: page,
    );

    if (getResult.error != null || getResult.data == null) {
      AppNotification notification = AppNotification(
        title: 'Erreur',
        body: getResult.error ?? 'Erreur inconnue',
        type: AppNotificationType.error,
      );
      emit(NewNotificationState(
        notification: notification,
        notificationStream: notificationStream,
        isImportant: false,
        notifications: notifications,
        page: page,
        totalPages: totalPages,
        unreadCount: unreadCount,
        context: context!,
        overlay: overlay,
      ));
    }

    notifications.clear();
    notifications.addAll(getResult.data!.$1);
    totalPages = getResult.data!.$2;
    unreadCount = getResult.data!.$3;
    notificationStream.addResponse(notifications);

    emit(NotificationLoaded(
      categories: categories,
      notificationStream: notificationStream,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
    ));
  }

  Future<void> _onChangeNotificationPageEvent(
      ChangeNotificationPageEvent event, Emitter<NotificationState> emit) async {
    page = event.page;

    final getResult = await notificationRepository.getNotifications(
      selectedCategories: categories,
      page: page,
    );

    if (getResult.error != null || getResult.data == null) {
      AppNotification notification = AppNotification(
        title: 'Erreur',
        body: getResult.error ?? 'Erreur inconnue',
        type: AppNotificationType.error,
      );
      emit(NewNotificationState(
        notification: notification,
        notificationStream: notificationStream,
        isImportant: false,
        notifications: notifications,
        page: page,
        totalPages: totalPages,
        unreadCount: unreadCount,
        context: context!,
        overlay: overlay,
      ));
    }

    notifications.addAll(getResult.data!.$1);
    totalPages = getResult.data!.$2;
    unreadCount = getResult.data!.$3;
    notificationStream.addResponse(notifications);

    emit(NotificationLoaded(
      categories: categories,
      notificationStream: notificationStream,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
    ));
  }

  FutureOr<void> _onSubscribeToNotificationsEvent(
      SubscribeToNotificationsEvent event, Emitter<NotificationState> emit) {
    _webSocketService.sendMessage(jsonEncode({
      'type': 'identify',
      'userId': event.userId,
    }));
  }

  FutureOr<void> _onChangeNotificationReadStatusEvent(
      ChangeNotificationReadStatusEvent event, Emitter<NotificationState> emit) async {
    final notificationIndex = notifications.indexWhere((element) => element.id == event.notification.id);
    notifications[notificationIndex] = notifications[notificationIndex].copyWith(
      status: AppNotificationStatus.read,
      readAt: DateTime.now(),
    );
    notificationStream.addResponse(notifications);
    emit(NotificationLoaded(
      categories: categories,
      notificationStream: notificationStream,
      notifications: notifications,
      page: page,
      totalPages: totalPages,
      unreadCount: unreadCount,
    ));

    final result = await notificationRepository.markNotificationAsRead(event.notification);

    if (result.error != null) {
      add(ErrorNotificationEvent(message: result.error));
      return;
    }
  }

  void _acknowledgeNotification(AppNotification notification) {
    try {
      if (notification.userId == null) {
        log('Notification does not have a user ID. Skipping acknowledgment.');
        return;
      }
      if (notification.id == null) {
        log('Notification does not have an ID. Skipping acknowledgment.');
        return;
      }

      // Send acknowledgment back to the server
      _webSocketService.sendMessage(jsonEncode({
        'type': 'ack',
        'userId': notification.userId!,
        'notificationId': notification.id!,
        // Include any other necessary information
      }));

      log('Acknowledgment sent for notification ID: ${notification.id}');
    } catch (error) {
      // Handle the error
      log('Error processing notification: $error');

      // Optionally, send an error acknowledgment to the server
      _webSocketService.sendMessage(jsonEncode({
        'type': 'ack',
        'userId': notification.userId!,
        'notificationId': notification.id!,
        'status': 'error',
        'errorMessage': error.toString(),
      }));

      log('Error acknowledgment sent for notification ID: ${notification.id}');
    }
  }

  void updateContext(BuildContext context) {
    this.context = context;
    // overlay?.dispose();
    // overlay = Overlay.of(context);
  }

  void reset() {
    notifications.clear();
    categories.clear();
    page = 1;
    totalPages = 0;
    unreadCount = 0;
    notificationStream.addResponse(notifications);
  }
}
