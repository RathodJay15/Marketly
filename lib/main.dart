import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketly/auth_gate.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
