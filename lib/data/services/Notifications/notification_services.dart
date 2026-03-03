import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/user/cart_screen.dart';
import 'package:marketly/presentation/user/orders/order_details_screen.dart';
import 'package:marketly/presentation/widgets/product_details.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationServices {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  //----------------------------------------------------------------------------
  // Notification Permission Request
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // FCM token initialization / token refresh and topic subscription
  //----------------------------------------------------------------------------

  Future<void> initFCM(String uid) async {
    String? token = await _messaging.getToken();

    if (token != null) {
      debugPrint("FCM TOKEN: $token");
      await authService.saveFcmToken(uid, token);
    }
  }

  Future<void> subscribeToAllUser() async {
    await FirebaseMessaging.instance.subscribeToTopic("all_users");
    debugPrint("Subscribed to topic all_users");
  }

  Future<void> subscribeToAdminOnly() async {
    await FirebaseMessaging.instance.subscribeToTopic("admin_only");
    debugPrint("Subscribed to topic admin_only");
  }

  void listenToTokenRefresh(Function(String) onRefresh) {
    _messaging.onTokenRefresh.listen(onRefresh);
  }

  //----------------------------------------------------------------------------
  // initialize localnotification
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // navigation handler
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // notification channel creation
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // Display localnotification
  //----------------------------------------------------------------------------

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

  //----------------------------------------------------------------------------
  // Display image in notification
  //----------------------------------------------------------------------------

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';

    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  Future<void> showBigPictureNotification({
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    final largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
    final bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');

    final BigPictureStyleInformation bigPictureStyle =
        BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: title,
          summaryText: body,
        );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'product_channel',
          'Product Notifications',
          channelDescription: 'Product alerts with image',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: bigPictureStyle,
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: payload,
    );
  }

  //----------------------------------------------------------------------------
  // Foreground notification listener
  //----------------------------------------------------------------------------

  void listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("-----FOREGROUND MESSAGE RECEIVED");

      final type = message.data['type'];
      final imageUrl = message.data['imageUrl'];

      String? payload;

      if (type == "new_product") {
        payload = message.data['productid'];
      } else if (type == "order_update") {
        payload = message.data['orderId'];
      } else if (type == "cart_expiry") {
        payload = "cart";
      }

      final title =
          message.notification?.title ??
          message.data['title'] ??
          'New Notification';

      final body = message.notification?.body ?? message.data['body'] ?? '';

      if (imageUrl != null && imageUrl.isNotEmpty) {
        await showBigPictureNotification(
          title: title,
          body: body,
          imageUrl: imageUrl,
          payload: payload,
        );
      } else {
        await showLocalNotification(title: title, body: body, payload: payload);
      }
    });
  }

  //----------------------------------------------------------------------------
  // Background(App State) notification navigation handler
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

      if (type == "cart_expiry") {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => CartScreen()),
        );
      }

      debugPrint("BACKGROUND DATA: ${message.data}");
    });
  }

  //----------------------------------------------------------------------------
  // Terminated(App State) notification navigation handler
  //----------------------------------------------------------------------------

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
    if (type == "cart_expiry") {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => CartScreen()),
      );
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
