import 'package:flutter/material.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/admin/dash_board_screen.dart';
import 'package:marketly/data/services/notification_services.dart';
import 'package:marketly/presentation/auth/login_screen.dart';
import 'package:marketly/presentation/user/home_screen.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<StatefulWidget> createState() => _authGateState();
}

class _authGateState extends State<AuthGate> {
  NotificationServices notificationServices = NotificationServices();
  bool _notificationInitialized = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 🔹 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
          );
        }

        final firebaseUser = snapshot.data;

        // 🔹 Not logged in
        if (firebaseUser == null) {
          context.read<UserProvider>().clearUser();
          return const LoginScreen();
        }

        // 🔹 Logged in → fetch profile
        return FutureBuilder(
          future: authService.getUserProfile(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primary,
                body: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              );
            }

            final userModel = userSnapshot.data;

            if (userModel == null) {
              return const LoginScreen();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<UserProvider>().setUser(userModel);
              }
            });

            if (!_notificationInitialized) {
              _notificationInitialized = true;

              notificationServices.requestNotificationPermission();

              notificationServices.initFCM(userModel.uid);

              notificationServices.listenToTokenRefresh((newToken) {
                authService.saveFcmToken(userModel.uid, newToken);
              });
            }

            if (userModel.role == 'admin') {
              return const DashBoardScreen();
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
