import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:marketly/auth_gate.dart';
// import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/firebase_options.dart';
// import 'package:marketly/presentation/admin/dash_board_screen.dart';
// import 'package:marketly/presentation/auth/login_screen.dart';
// import 'package:marketly/presentation/user/home_screen.dart';
// import 'package:marketly/core/data_instance/auth_locator.dart';
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
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: MarketTheme.light,
        darkTheme: MarketTheme.dark,
        home: const AuthGate(),
      ),
    );
  }
}
