import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/presentation/admin/dash_board_screen.dart';
import 'package:marketly/data/services/Notifications/notification_services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marketly/presentation/auth/login_screen.dart';
import 'package:marketly/presentation/user/home_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/favorites_provider.dart';
import 'package:marketly/providers/notification_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<StatefulWidget> createState() => _authGateState();
}

class _authGateState extends State<AuthGate> {
  NotificationServices notificationServices = NotificationServices();
  late StreamSubscription _connectivitySubscription;
  bool _notificationInitialized = false;

  @override
  void initState() {
    super.initState();
    _init();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) {
      if (result == ConnectivityResult.none) {
        _checkInternet(context);
      }
    });
  }

  Future<void> _init() async {
    bool hasInternet = await _checkInternet(context);
    if (!mounted) return;
    if (!hasInternet) return;
  }

  Future<bool> _checkInternet(BuildContext context) async {
    final results = await Connectivity().checkConnectivity();

    if (results.contains(ConnectivityResult.none)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              AppConstants.noInternet,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            content: Text(
              AppConstants.turnOnInternet,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _checkInternet(context);
                },
                child: Text(
                  AppConstants.retry,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: Center(
              child: SpinKitRotatingCircle(
                size: 100,
                itemBuilder: (context, index) {
                  return Container(
                    height: 200,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(130),
                        bottomRight: Radius.circular(130),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: Theme.of(context).colorScheme.onPrimary,
                      // safer than withValues
                    ),
                  );
                },
              ),
            ),
          );
        }

        final firebaseUser = snapshot.data;

        // Not logged in
        if (firebaseUser == null) {
          context.read<UserProvider>().clearUser();
          return const LoginScreen();
        }

        // Logged in -> fetch profile
        return FutureBuilder(
          future: authService.getUserProfile(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primary,
                body: Center(
                  child: SpinKitRotatingCircle(
                    size: 100,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(130),
                            bottomRight: Radius.circular(130),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          color: Theme.of(context).colorScheme.onPrimary,
                          // safer than withValues
                        ),
                      );
                    },
                  ),
                ),
              );
            }

            final userModel = userSnapshot.data;

            if (userModel == null) {
              return const LoginScreen();
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final notificationProvider = context.read<NotificationProvider>();
              final cartProvider = context.read<CartProvider>();
              if (context.mounted) {
                context.read<UserProvider>().setUser(userModel);
                notificationProvider.listenToNotifications(firebaseUser.uid);
                cartProvider.startListening();
                context.read<FavoritesProvider>().listenToLikes(
                  firebaseUser.uid,
                );
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
              notificationServices.subscribeToAdminOnly();
              return const DashBoardScreen();
            }
            notificationServices.subscribeToAllUser();
            return const HomeScreen();
          },
        );
      },
    );
  }
}
