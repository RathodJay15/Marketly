import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketly/firebase_options.dart';
import 'presentation/auth/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: MarketTheme.light,
      darkTheme: MarketTheme.dark,
      home: LoginScreen(),
    );
  }
}
