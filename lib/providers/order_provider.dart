import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/data/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
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
      paymentStatus: 'PENDING',
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

  void applyCouponDiscount({
    required double couponDiscountAmount,
    required int couponPercentage,
    required String couponCode,
  }) {
    if (_order == null) return;

    final pricing = Map<String, dynamic>.from(_order!.pricing);

    final subtotal = pricing["subtotal"] ?? 0.0;

    final total = subtotal - couponDiscountAmount;

    pricing["couponDiscount"] = couponDiscountAmount;
    pricing["couponPercentage"] = couponPercentage;
    pricing["couponCode"] = couponCode;
    pricing["total"] = total;

    _order = _order!.copyWith(pricing: pricing);

    notifyListeners();
  }

  void removeCouponDiscount() {
    if (_order == null) return;

    final pricing = Map<String, dynamic>.from(_order!.pricing);

    final subtotal = pricing["subtotal"] ?? 0.0;

    pricing["couponDiscount"] = 0.0;
    pricing["couponPercentage"] = 0.0;
    pricing["couponCode"] = null;
    pricing["total"] = subtotal;

    _order = _order!.copyWith(pricing: pricing);

    notifyListeners();
  }

  void setPaymentMethod(String method) {
    if (_order == null) return;

    String status;

    if (method == 'COD') {
      status = 'PENDING';
    } else {
      status = 'PAID';
    }

    _order = _order!.copyWith(paymentMethod: method, paymentStatus: status);

    notifyListeners();
  }

  void setRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    if (_order == null) return;

    _order = _order!.copyWith(razorpayPaymentId: paymentId);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // PLACE ORDER
  // ---------------------------------------------------------------------------

  Future<OrderModel?> placeOrder() async {
    if (_order == null) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final placedOrder = await _orderService.placeOrder(_order!);
      _order = null;
      return placedOrder;
    } catch (e) {
      debugPrint('Place order failed: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  //  FETCH ORDERS
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
  //  FETCH ORDER BY ID
  // ---------------------------------------------------------------------------

  Future<OrderModel?> fetchOrderById(String orderId) async {
    try {
      final order = await _orderService.fetchOrderById(orderId);
      return order;
    } catch (e) {
      debugPrint('Error fetching single order: $e');
      return null;
    } finally {
      _isLoading = false;
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
