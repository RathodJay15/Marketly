import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketly/providers/auth_provider.dart';
import 'package:marketly/presentation/auth/login_screen.dart';
import 'package:marketly/presentation/user/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // App starting / checking auth
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Logged in
    if (authProvider.isLoggedIn) {
      return HomeScreen();
    }

    // Not logged in
    return const LoginScreen();
  }
}
