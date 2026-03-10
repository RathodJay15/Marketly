import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String code;
  final int discountPercentage;
  final int minOrderAmount;
  final bool isActive;
  final bool firstOrderOnly;
  final Timestamp? expiryDate;

  CouponModel({
    required this.code,
    required this.discountPercentage,
    required this.minOrderAmount,
    required this.isActive,
    required this.firstOrderOnly,
    this.expiryDate,
  });

  factory CouponModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return CouponModel(
      code: doc['code'],
      discountPercentage: doc['discountPercentage'],
      minOrderAmount: doc['minOrderAmount'],
      isActive: doc['isActive'],
      firstOrderOnly: doc['firstOrderOnly'] ?? false,
    );
  }
}
