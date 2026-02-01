import 'package:dio/dio.dart';
import 'package:murya/models/notifications.dart';
import 'package:murya/repositories/base.repository.dart';
import 'package:murya/services/cache.service.dart';

class NotificationRepository extends BaseRepository {
  final CacheService cacheService;

  NotificationRepository({CacheService? cacheService}) : cacheService = cacheService ?? CacheService();

  String _notificationsCacheKey(List<AppNotificationCategory> categories, int page) {
    final sorted = [...categories]..sort((a, b) => a.value.compareTo(b.value));
    final key = sorted.map((c) => c.value).join(',');
    return 'notifications_${key}_$page';
  }

  Future<Result<(List<AppNotification>, int, int)>> getNotifications({
    required List<AppNotificationCategory> selectedCategories,
    required int page,
  }) async {
    return AppResponse.execute(
      action: () async {
        Map<String, dynamic> queryParams = {};

        if (page > 0) {
          queryParams["page"] = page;
        }

        if (selectedCategories.isNotEmpty) {
          queryParams["categories[]"] = selectedCategories.map((category) => category.value).toSet().toList();
        }
        if (selectedCategories.contains(AppNotificationCategory.reservationRead)) {
          queryParams["status"] = "READ";
        } else if (selectedCategories.contains(AppNotificationCategory.reservationUnread)) {
          queryParams["status"] = "UNREAD";
        }

        final Response response = await api.dio.get(
          '/notifications',
          queryParameters: queryParams,
        );

        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response.data["data"]["notifications"]);
        final int unreadCount = response.data["data"]["unread"] as int;

        final List<AppNotification> notifications = data.map((notification) {
          return AppNotification.fromJson(notification);
        }).toList();

        final totalPages = response.data["pagination"]["totalPages"];

        await cacheService.save(
          _notificationsCacheKey(selectedCategories, page),
          {
            'notifications': data,
            'totalPages': totalPages,
            'unread': unreadCount,
          },
        );

        return ResultWithMessage(
          (notifications, totalPages, unreadCount),
          response.data["message"] as String?,
        );
      },
      parentFunctionName: 'NotificationRepository -> getNotification',
      errorResult: (<AppNotification>[], 0, 0),
    );
  }

  Future<Result<(List<AppNotification>, int, int)>> getNotificationsCached({
    required List<AppNotificationCategory> selectedCategories,
    required int page,
  }) async {
    try {
      final cachedData = await cacheService.get(_notificationsCacheKey(selectedCategories, page));
      if (cachedData != null) {
        final raw = cachedData['notifications'];
        final totalPages = cachedData['totalPages'] as int? ?? 0;
        final unread = cachedData['unread'] as int? ?? 0;
        if (raw is List) {
          final data =
              raw.whereType<Map>().map((item) => AppNotification.fromJson(Map<String, dynamic>.from(item))).toList();
          return Result.success((data, totalPages, unread), null);
        }
      }
    } catch (_) {
      // ignore cache errors
    }
    return Result.success((<AppNotification>[], 0, 0), null);
  }

  Future<Result<bool>> markNotificationAsRead(AppNotification notification) async {
    return AppResponse.execute(
      action: () async {
        await api.dio.post(
          '/notifications/change-status',
          data: {
            "ids": [notification.id],
            "status": "READ",
          },
        );
        return true;
      },
      parentFunctionName: 'NotificationRepository -> markNotificationAsRead',
      errorResult: false,
    );
  }
}
