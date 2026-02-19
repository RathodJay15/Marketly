import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
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
      if (message.notification != null) {
        final productId = message.data['productid']; //'Hqp76dSEh6keEiIKEi1o'
        // final productId = 'Hqp76dSEh6keEiIKEi1o';
        showLocalNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          payload: productId,
        );
      }
    });
  }

  //----------------------------------------------------------------------------
  void handleBackgroundNavigation(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final productId = message.data['productid'];
      // final productId = 'Hqp76dSEh6keEiIKEi1o';

      print("BACKGROUND DATA: ${message.data}");

      if (productId != null) {
        _handleNavigation(productId, navigatorKey);
      }
    });
  }

  Future<void> handleTerminatedNavigation(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    final message = await FirebaseMessaging.instance.getInitialMessage();

    if (message == null) return;

    print("TERMINATED MESSAGE DATA: ${message.data}");

    final productId = message.data['productid'];
    // final productId = 'Hqp76dSEh6keEiIKEi1o';
    print("TERMINATED DATA: ${message.data}");

    if (productId != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
          ),
        );
      });
    }
  }
}
