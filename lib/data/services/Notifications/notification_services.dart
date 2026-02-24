import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/user/orders/order_details_screen.dart';
import 'package:marketly/presentation/widgets/product_details.dart';

class NotificationServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint("Permission Granted!");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint("Provisional Permission!");
    } else {
      debugPrint("Permission Denied!");
    }
  }

  Future<void> initFCM(String uid) async {
    String? token = await _messaging.getToken();

    if (token != null) {
      debugPrint("FCM TOKEN: $token");
      await authService.saveFcmToken(uid, token);
    }
    await FirebaseMessaging.instance.subscribeToTopic("all_users");
    debugPrint("Subscribed to topic all_users");
  }

  void listenToTokenRefresh(Function(String) onRefresh) {
    _messaging.onTokenRefresh.listen(onRefresh);
  }

  Future<void> initLocalNotifications(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final productId = response.payload;

        if (productId != null) {
          _handleNavigation(productId, navigatorKey);
        }
      },
    );
  }

  void _handleNavigation(
    String productId,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(productId: productId),
      ),
    );
  }

  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showLocalNotification({
    required String? title,
    required String? body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("-----FOREGROUND MESSAGE RECEIVED");
      debugPrint("-----Notification: ${message.notification}");
      debugPrint("-----Data: ${message.data}");

      final type = message.data['type'];

      String? payload;

      if (type == "new_product") {
        payload = message.data['productid'];
      } else if (type == "order_update") {
        payload = message.data['orderId'];
      }

      final title =
          message.notification?.title ??
          message.data['title'] ??
          'New Notification';

      final body = message.notification?.body ?? message.data['body'] ?? '';

      showLocalNotification(title: title, body: body, payload: payload);
    });
  }

  //----------------------------------------------------------------------------
  void handleBackgroundNavigation(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final type = message.data['type'];

      if (type == "new_product") {
        final productId = message.data['productid'];
        _handleNavigation(productId, navigatorKey);
      }

      if (type == "order_update") {
        final orderId = message.data['orderId'];

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(orderId: orderId),
          ),
        );
      }

      debugPrint("BACKGROUND DATA: ${message.data}");
    });
  }

  Future<void> handleTerminatedNavigation(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message == null) return;

    debugPrint("TERMINATED MESSAGE DATA: ${message.data}");

    final type = message.data['type'];

    if (type == "new_product") {
      final productId = message.data['productid'];

      if (productId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
          ),
        );
      }
    }

    if (type == "order_update") {
      final orderId = message.data['orderId'];

      if (orderId != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(orderId: orderId),
          ),
        );
      }
    }
  }
}
