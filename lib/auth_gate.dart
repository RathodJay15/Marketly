import 'package:flutter/material.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/admin/dash_board_screen.dart';
import 'package:marketly/presentation/auth/login_screen.dart';
import 'package:marketly/presentation/user/home_screen.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _authGateState();
}

class _authGateState extends State<AuthGate> {
  bool _isCheckingAuth = true;
  @override
  void initState() {
    super.initState();

    authService.authStateChanges.listen((firebaseUser) async {
      final userProvider = context.read<UserProvider>();

      if (firebaseUser == null) {
        userProvider.clearUser();
        setState(() => _isCheckingAuth = false);
        return;
      }

      final userModel = await authService.getUserProfile(firebaseUser.uid);

      if (userModel != null) {
        userProvider.setUser(userModel);
      }
      setState(() => _isCheckingAuth = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      );
    }

    if (user == null) {
      return const LoginScreen();
    }

    if (user.role == 'admin') {
      return const DashBoardScreen();
    }

    return const HomeScreen();
  }
}
