import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // Total users
  // ------------------------------------------------------------
  Future<int> getTotalUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.size;
  }

  //-------------------------------------------------------------
  // Active users
  //-------------------------------------------------------------
  Future<int> getTotalActiveUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('isDeleted', isEqualTo: false)
        .get();

    debugPrint(snapshot.size.toString());

    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total orders & pending, confirmed
  // ------------------------------------------------------------
  Future<int> getTotalOrders() async {
    final snapshot = await _firestore.collection('orders').get();
    return snapshot.size;
  }

  Future<Map<String, int>> getOrderStatusStats() async {
    final snapshot = await _firestore.collection('orders').get();

    int confirmed = 0;
    int pending = 0;

    for (var doc in snapshot.docs) {
      final List<dynamic> timeline = doc['statusTimeline'] ?? [];

      bool isConfirmed = timeline.any(
        (status) => status['status'] == 'ORDER_CONFIRMED',
      );

      if (isConfirmed) {
        confirmed++;
      } else {
        pending++;
      }
    }

    return {'confirmedOrders': confirmed, 'pendingOrders': pending};
  }

  // ------------------------------------------------------------
  // Total products
  // ------------------------------------------------------------
  Future<int> getTotalProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total categories
  // ------------------------------------------------------------
  Future<int> getTotalCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total Active categories
  // ------------------------------------------------------------
  Future<int> getTotalActiveCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.size;
  }

  // ------------------------------------------------------------
  // Total Inactive categories
  // ------------------------------------------------------------
  Future<int> getTotalInactiveCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .where('isActive', isEqualTo: false)
        .get();

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
    final activeUserFuture = getTotalActiveUsers();
    final ordersFuture = getTotalOrders();
    final revenueFuture = getTotalRevenue();
    final productFuture = getTotalProducts();
    final totalCategoriesFuture = getTotalCategories();
    final activeCategoriesFuture = getTotalActiveCategories();
    final inactiveCategoriesFuture = getTotalInactiveCategories();
    final orderStatusFuture = getOrderStatusStats();

    final results = await Future.wait([
      usersFuture,
      ordersFuture,
      revenueFuture,
      productFuture,
      totalCategoriesFuture,
      activeCategoriesFuture,
      inactiveCategoriesFuture,
      orderStatusFuture,
      activeUserFuture,
    ]);

    return {
      'totalUsers': results[0],
      'totalOrders': results[1],
      'totalRevenue': results[2],
      'totalProducts': results[3],
      'totalCategories': results[4],
      'activeCategories': results[5],
      'inactiveCategories': results[6],
      'orderStatus': results[7],
      'activeUsers': results[8],
    };
  }
}
