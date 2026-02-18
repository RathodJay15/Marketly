import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:marketly/auth_gate.dart';
import 'package:marketly/data/services/notification_services.dart';
import 'package:marketly/firebase_options.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:marketly/providers/admin/admin_order_provider.dart';
import 'package:marketly/providers/admin/admin_user_provider.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/admin/admin_categories_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/user_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notificationService = NotificationServices();

  await notificationService.initLocalNotifications(navigatorKey);
  await notificationService.createNotificationChannel();
  notificationService.listenToForegroundMessages();

  runApp(MainApp(navigatorKey: navigatorKey));
}

class MainApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MainApp({super.key, required this.navigatorKey});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final NotificationServices _notificationService = NotificationServices();

  @override
  void initState() {
    super.initState();

    // Delay to ensure navigator is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationService.handleBackgroundNavigation(widget.navigatorKey);
      _notificationService.handleTerminatedNavigation(widget.navigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
        ChangeNotifierProvider(create: (_) => AdminUserProvider()),
      ],
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return MaterialApp(
            navigatorKey: widget.navigatorKey,
            debugShowCheckedModeBanner: false,
            themeMode: userProvider.themeMode,
            theme: MarketTheme.light,
            darkTheme: MarketTheme.dark,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
// class MainApp extends StatelessWidget {
//   final GlobalKey<NavigatorState> navigatorKey;

//   MainApp({super.key, required this.navigatorKey});

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => CategoryProvider()),
//         ChangeNotifierProvider(create: (_) => ProductProvider()),
//         ChangeNotifierProvider(create: (_) => NavigationProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(create: (_) => OrderProvider()),
//         ChangeNotifierProvider(create: (_) => AdminCategoryProvider()),
//         ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
//         ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
//         ChangeNotifierProvider(create: (_) => AdminUserProvider()),
//       ],
//       child: Consumer<UserProvider>(
//         builder: (context, userProvider, _) {
//           return MaterialApp(
//             navigatorKey: navigatorKey,
//             debugShowCheckedModeBanner: false,
//             themeMode: userProvider.themeMode,
//             theme: MarketTheme.light,
//             darkTheme: MarketTheme.dark,
//             home: const AuthGate(),
//           );
//         },
//       ),
//     );
//   }
// }
