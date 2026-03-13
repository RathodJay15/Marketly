import 'package:flutter/material.dart';
import 'package:marketly/data/models/coupon_model.dart';
import 'package:marketly/data/services/coupon_service.dart';
import 'package:marketly/data/services/order_service.dart';
import 'package:marketly/providers/order_provider.dart';

class CouponProvider extends ChangeNotifier {
  final CouponServices _services = CouponServices();
  final OrderService _orderService = OrderService();

  CouponModel? appliedCoupon;
  double discountAmount = 0;

  bool isApplied = false;

  Future<String?> appliyCouponCode(
    String code,
    double subtotal,
    String userId,
    OrderProvider orderProvider,
  ) async {
    final coupon = await _services.getCoupon(code);

    if (coupon == null) {
      return 'Invalid coupon code';
    }

    if (!coupon.isActive) {
      return 'Coupon is not active';
    }

    final alreadyUsed = await _services.hasUserUsedCoupon(userId, coupon.code);
    if (alreadyUsed) {
      return "You have already used this coupon";
    }

    if (coupon.expiryDate.toDate().isBefore(DateTime.now())) {
      return 'Coupon expired';
    }

    if (subtotal < coupon.minOrderAmount) {
      return 'Minimum order ₹${coupon.minOrderAmount} required';
    }

    if (coupon.firstOrderOnly) {
      final hasOrdered = await _orderService.hasUserPlacedOrder(userId);

      if (hasOrdered) {
        return "This coupon is only valid for your first order";
      }
    }

    appliedCoupon = coupon;
    isApplied = true;

    discountAmount = subtotal * (coupon.discountPercentage / 100);

    orderProvider.applyCouponDiscount(
      couponDiscountAmount: discountAmount,
      couponPercentage: coupon.discountPercentage,
      couponCode: coupon.code,
    );
    debugPrint("coupon applied");
    notifyListeners();
    return null;
  }

  void removeCoupon(OrderProvider orderProvider) {
    appliedCoupon = null;
    discountAmount = 0;
    isApplied = false;

    orderProvider.removeCouponDiscount();

    notifyListeners();
  }
}
