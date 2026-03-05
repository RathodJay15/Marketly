import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  bool _isCartLocked = false;
  bool get isCartLocked => _isCartLocked;

  // ─────────────────────────────────────────────
  // Timer
  // ─────────────────────────────────────────────

  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  Duration get remainingTime => _remainingTime;

  void _startCountdown(DateTime expiresAt) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final difference = expiresAt.difference(DateTime.now());

      if (difference.isNegative) {
        timer.cancel();
        clearCart();
      } else {
        _remainingTime = difference;
        notifyListeners();
      }
    });
  }

  // ─────────────────────────────────────────────
  // START LISTENING (call after login)
  // ─────────────────────────────────────────────
  void startListening() {
    if (_uid == null) return;

    _subscription?.cancel();

    // Listen to items
    _subscription = _cartService
        .cartStream(_uid!)
        .listen(
          (items) {
            _items = items;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Cart Stream Error: $error");
          },
        );

    // Listen to cart metadata for expiration
    _cartService.cartMetaStream(_uid!).listen((snapshot) {
      // If cart document is deleted
      if (!snapshot.exists) {
        _timer?.cancel();
        _remainingTime = Duration.zero;
        _items = [];
        notifyListeners();
        return;
      }

      final data = snapshot.data();
      if (data == null) return;

      final expiresAt = data['expiresAt'] as Timestamp?;
      if (expiresAt == null) return;

      _startCountdown(expiresAt.toDate());
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

  double get subTotal => _items.fold(0.0, (sum, item) => sum + item.total);

  double get finalTotal =>
      _items.fold(0.0, (sum, item) => sum + item.discountedTotal);

  double get totalDiscount => subTotal - finalTotal;

  double get totalDiscountPercentage {
    if (subTotal == 0) return 0;
    return ((subTotal - finalTotal) / subTotal) * 100;
  }

  // ─────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────

  CartItemModel? getItemByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (_) {
      return null;
    }
  }

  Future<void> addToCart(CartItemModel item) async {
    if (_isCartLocked) return;
    if (_uid == null) return;
    await _cartService.addToCart(uid: _uid!, item: item);
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (_isCartLocked) return;
    if (_uid == null) return;
    await _cartService.updateQuantity(
      uid: _uid!,
      cartItemId: cartItemId,
      quantity: quantity,
    );
  }

  Future<void> removeItem(String cartItemId) async {
    if (_isCartLocked) return;
    if (_uid == null) return;
    await _cartService.removeItem(_uid!, cartItemId);
  }

  void lockCart() {
    _isCartLocked = true;
    notifyListeners();
  }

  void unlockCart() {
    _isCartLocked = false;
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (_isCartLocked) return;
    if (_uid == null) return;
    await _cartService.clearCart(_uid!);
  }
}
