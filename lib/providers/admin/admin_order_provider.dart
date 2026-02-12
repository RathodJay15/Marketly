import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/data/services/order_service.dart';

class AdminOrderProvider extends ChangeNotifier {
  OrderService _orderService = OrderService();
  OrderModel? _order;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  OrderModel? get order => _order;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  // ---------------------------------------------------------------------------
  //  FETCH ORDERS (this is what you asked for)
  // ---------------------------------------------------------------------------

  Future<void> fetchAllOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getAllOrders();
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await _orderService.updateOrderStatus(orderId: orderId, status: status);

    final index = _orders.indexWhere((o) => o.id == orderId);

    if (index != -1) {
      final updatedTimeline = List<Map<String, dynamic>>.from(
        _orders[index].statusTimeline,
      );

      updatedTimeline.add({"status": status, "time": Timestamp.now()});

      _orders[index] = _orders[index].copyWith(statusTimeline: updatedTimeline);

      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  void clearOrder() {
    _order = null;
    notifyListeners();
  }
}
