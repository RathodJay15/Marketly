import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:marketly/controllers/auth_controller.dart';
import 'package:marketly/data/services/auth/auth_service.dart';
import 'package:marketly/firebase_options.dart';
import 'package:marketly/presentation/auth/authWrapper.dart';
import 'package:marketly/providers/auth_provider.dart';
import 'package:provider/provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) =>
              AuthProvider(AuthController(AuthService()))..loadCurrentUser(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: MarketTheme.light,
        darkTheme: MarketTheme.dark,
        home: AuthWrapper(),
      ),
    );
  }
}
