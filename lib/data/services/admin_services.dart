import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // Total users
  // ------------------------------------------------------------
  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total orders
  // ------------------------------------------------------------
  Future<int> getTotalOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total revenue
  // ------------------------------------------------------------
  Future<double> getTotalRevenue() async {
    final snapshot = await _firestore.collection('orders').get();

    double revenue = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      //  SAFE nested read
      final pricing = data['pricing'];
      if (pricing is Map && pricing['total'] != null) {
        final total = pricing['total'];

        if (total is int) {
          revenue += total.toDouble();
        } else if (total is double) {
          revenue += total;
        }
      }
    }

    return revenue;
  }

  // ------------------------------------------------------------
  // Dashboard summary (recommended)
  // ------------------------------------------------------------
  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersFuture = getTotalUsers();
    final ordersFuture = getTotalOrders();
    final revenueFuture = getTotalRevenue();

    final results = await Future.wait([
      usersFuture,
      ordersFuture,
      revenueFuture,
    ]);

    return {
      'totalUsers': results[0],
      'totalOrders': results[1],
      'totalRevenue': results[2],
    };
  }
}
