import 'package:flutter/material.dart';
import 'package:marketly/data/services/admin_services.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  Map<String, dynamic>? stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final adminService = AdminService();
    final data = await adminService.getDashboardStats();

    if (!mounted) return;

    setState(() {
      stats = data;
      _loading = false;
    });
  }

  Future<void> onLogout() async {
    await AuthService().logout();
    context.read<UserProvider>().clearUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          "Admin Dashboard",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            onPressed: onLogout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [_stats()]),
    );
  }

  Widget _stats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            _statRow(
              icon: Icons.person,
              label: 'Users',
              value: stats!['totalUsers'].toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _statRow(
              icon: Icons.list_rounded,
              label: 'Orders',
              value: stats!['totalOrders'].toString(),
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _statRow(
              icon: Icons.attach_money_rounded,
              label: 'Revenue',
              value: '\$ ${stats!['totalRevenue'].toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.onInverseSurface,
          size: 40,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
