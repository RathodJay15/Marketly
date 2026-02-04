import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/cart_item_model.dart';
import '../data/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  StreamSubscription? _subscription;

  List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // ─────────────────────────────────────────────
  // START LISTENING (call after login)
  // ─────────────────────────────────────────────
  void startListening() {
    if (_uid == null) return;

    _subscription?.cancel();
    _subscription = _cartService.cartStream(_uid!).listen((items) {
      _items = items;
      notifyListeners();
    });
  }

  // ─────────────────────────────────────────────
  // STOP LISTENING (call on logout)
  // ─────────────────────────────────────────────
  void stopListening() {
    _subscription?.cancel();
    _items = [];
    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // DERIVED TOTALS (SAFE)
  // ─────────────────────────────────────────────
  int get totalProducts => _items.length;

  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.discountedTotal);

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────
  Future<void> addToCart(CartItemModel item) async {
    if (_uid == null) return;
    await _cartService.addToCart(uid: _uid!, item: item);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_uid == null) return;
    await _cartService.updateQuantity(
      uid: _uid!,
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  Future<void> removeItem(String cartItemId) async {
    if (_uid == null) return;
    await _cartService.removeItem(_uid!, cartItemId);
  }

  Future<void> clearCart() async {
    if (_uid == null) return;
    await _cartService.clearCart(_uid!);
  }
}
