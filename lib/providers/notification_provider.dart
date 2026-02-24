import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/notification_model.dart';
import 'package:marketly/data/services/notifications/user_notification_services.dart';

class NotificationProvider extends ChangeNotifier {
  final UserNotificationServices _notificationService =
      UserNotificationServices();

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  StreamSubscription<List<AppNotification>>? _subscription;

  void listenToNotifications(String userId) {
    _subscription?.cancel(); // prevent duplicate listeners

    _subscription = _notificationService.getUserNotifications(userId).listen((
      data,
    ) {
      _notifications = data;
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationService.markAsRead(notificationId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
