import 'package:flutter/material.dart';
import 'package:marketly/data/models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  OrderModel? _order;

  OrderModel? get order => _order;

  // ---------------------------------------------------------------------------
  // Init
  // ---------------------------------------------------------------------------

  void initOrder({
    required String userId,
    required Map<String, dynamic> userInfo,
  }) {
    _order = OrderModel(
      id: '',
      userId: userId,
      userInfo: userInfo,
      address: {},
      items: [],
      pricing: {},
      paymentMethod: '',
      status: 'pending',
      createdAt: DateTime.now(),
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
  // Clear
  // ---------------------------------------------------------------------------

  void clearOrder() {
    _order = null;
    notifyListeners();
  }
}
