import 'package:flutter/material.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<StatefulWidget> createState() => _dashBoardScreenState();
}

class _dashBoardScreenState extends State<DashBoardScreen> {
  Future<void> onLogout() async {
    await AuthService().logout(); // Firebase session
    context.read<UserProvider>().clearUser(); // App state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: const Text("Marketly"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              onLogout();
            },
          ),
        ],
      ),
      body: Center(child: Text('admin dashboard')),
    );
  }
}
