import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/coupon_model.dart';
import 'package:marketly/data/services/coupon_service.dart';

class AdminCouponProvider extends ChangeNotifier {
  final CouponServices _couponService = CouponServices();

  List<CouponModel> _coupons = [];
  bool _isLoading = false;
  String? _error;

  List<CouponModel> get coupons => _coupons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ------------------------------------------------------------
  // Fetch All Categories (Admin View)
  // ------------------------------------------------------------
  Future<void> fetchAllCoupons() async {
    try {
      _setLoading(true);
      _coupons = await _couponService.getAllCoupons();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Add Category
  // ------------------------------------------------------------
  Future<bool> addCoupon({
    required String code,
    required int discountPercentage,
    required bool isActive,
    required bool firstOrderOnly,
    required int minOrderAmount,
    required int expiriesInDays,
  }) async {
    try {
      _setLoading(true);

      await _couponService.addCoupon(
        code: code,
        discountPercentage: discountPercentage,
        expiriesInDays: expiriesInDays,
        firstOrderOnly: firstOrderOnly,
        minOrderAmount: minOrderAmount,
        isActive: isActive,
      );

      await fetchAllCoupons(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Activate / Deactivate Category
  // ------------------------------------------------------------
  Future<void> toggleCouponStatus({
    required String code,
    required bool isActive,
  }) async {
    try {
      await _couponService.updateCouponActiveState(
        code: code,
        isActive: isActive,
      );

      final index = _coupons.indexWhere((category) => category.code == code);

      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(isActive: isActive);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // Update Coupon (Title, Slug, Active Status)
  // ------------------------------------------------------------
  Future<bool> updateCoupon({
    required String oldCode,
    required String code,
    required int discountPercentage,
    required bool isActive,
    required bool firstOrderOnly,
    required int expiriesInDays,
    required int minOrderAmount,
  }) async {
    try {
      _setLoading(true);

      await _couponService.updateCoupon(
        code: code,
        discountPercentage: discountPercentage,
        expiriesInDays: expiriesInDays,
        firstOrderOnly: firstOrderOnly,
        minOrderAmount: minOrderAmount,
        oldCode: oldCode,
        isActive: isActive,
      );

      final index = _coupons.indexWhere((category) => category.code == oldCode);

      if (index != -1) {
        _coupons[index] = _coupons[index].copyWith(
          code: code,
          discountPercentage: discountPercentage,
          expiryDate: Timestamp.fromDate(
            DateTime.now().add(Duration(days: expiriesInDays)),
          ),
          firstOrderOnly: firstOrderOnly,
          minOrderAmount: minOrderAmount,
          isActive: isActive,
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Delete Category
  // ------------------------------------------------------------
  Future<void> deleteCategory(String code) async {
    try {
      await _couponService.deleteCoupon(code);

      _coupons.removeWhere((category) => category.code == code);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // Private Loading Setter
  // ------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
