import 'package:dio/dio.dart';
import 'package:murya/models/notifications.dart';
import 'package:murya/repositories/base.repository.dart';

class NotificationRepository extends BaseRepository {
  NotificationRepository();

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

        return ResultWithMessage(
          (notifications, totalPages, unreadCount),
          response.data["message"] as String?,
        );
      },
      parentFunctionName: 'NotificationRepository -> getNotification',
      errorResult: (<AppNotification>[], 0, 0),
    );
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
