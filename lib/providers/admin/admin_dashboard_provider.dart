import 'package:flutter/material.dart';
import 'package:marketly/data/services/admin_services.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> _stats = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get stats => _stats;

  // ------------------------------------------------------------
  // Fetch Dashboard Stats
  // ------------------------------------------------------------
  Future<void> fetchDashboardStats() async {
    try {
      _setLoading(true);

      final data = await _adminService.getDashboardStats();
      _stats = data;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Refresh Dashboard
  // ------------------------------------------------------------
  Future<void> refreshDashboard() async {
    await fetchDashboardStats();
  }

  // ------------------------------------------------------------
  // Private Loading Setter
  // ------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // Helper Getters (Clean UI Usage)
  // ------------------------------------------------------------
  int get totalUsers => _stats['totalUsers'] ?? 0;
  int get totalOrders => _stats['totalOrders'] ?? 0;
  double get totalRevenue => _stats['totalRevenue'] ?? 0.0;
  int get totalProducts => _stats['totalProducts'] ?? 0;
  int get totalCategories => _stats['totalCategories'] ?? 0;
  int get activeCategories => _stats['activeCategories'] ?? 0;
  int get inactiveCategories => _stats['inactiveCategories'] ?? 0;
  int get activeUsers => _stats['activeUsers'] ?? 0;

  int get confirmedOrders => (_stats['orderStatus']?['confirmedOrders']) ?? 0;

  int get pendingOrders => (_stats['orderStatus']?['pendingOrders']) ?? 0;
}
