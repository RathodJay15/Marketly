import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/data/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderService _orderService = OrderService();
  OrderModel? _order;
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  OrderModel? get order => _order;
  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  // ---------------------------------------------------------------------------
  // Initialize order
  // ---------------------------------------------------------------------------

  void initOrder({
    required String userId,
    required Map<String, dynamic> userInfo,
  }) {
    _order = OrderModel(
      id: '',
      orderNumber: '',
      sequence: 0,
      userId: userId,
      userInfo: userInfo,
      address: {},
      items: [],
      pricing: {},
      paymentMethod: '',
      statusTimeline: [
        {"status": "ORDER_PLACED", "time": Timestamp.now()},
      ],
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Setters per step
  // ---------------------------------------------------------------------------

  void setAddress(Map<String, dynamic> address) {
    if (_order == null) return;
    _order = _order!.copyWith(address: address);
    notifyListeners();
  }

  void setItems(List<Map<String, dynamic>> items) {
    if (_order == null) return;
    _order = _order!.copyWith(items: items);
    notifyListeners();
  }

  void setPricing(Map<String, dynamic> pricing) {
    if (_order == null) return;
    _order = _order!.copyWith(pricing: pricing);
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    if (_order == null) return;
    _order = _order!.copyWith(paymentMethod: method);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PLACE ORDER
  // ---------------------------------------------------------------------------

  Future<void> placeOrder() async {
    if (_order == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _orderService.placeOrder(_order!);
      _order = null;
    } catch (e) {
      debugPrint('Place order failed: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  //  FETCH ORDERS (this is what you asked for)
  // ---------------------------------------------------------------------------

  Future<void> fetchOrders(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders(userId);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      _orders = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  void clearOrder() {
    _order = null;
    notifyListeners();
  }
}
