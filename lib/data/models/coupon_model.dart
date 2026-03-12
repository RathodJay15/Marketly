import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String code;
  final int discountPercentage;
  final int minOrderAmount;
  final bool isActive;
  final bool firstOrderOnly;
  final Timestamp expiryDate;

  CouponModel({
    required this.code,
    required this.discountPercentage,
    required this.minOrderAmount,
    required this.isActive,
    required this.firstOrderOnly,
    required this.expiryDate,
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
      expiryDate: doc['expiryDate'],
    );
  }

  CouponModel copyWith({
    String? code,
    int? discountPercentage,
    int? minOrderAmount,
    bool? isActive,
    bool? firstOrderOnly,
    Timestamp? expiryDate,
  }) {
    return CouponModel(
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isActive: isActive ?? this.isActive,
      firstOrderOnly: firstOrderOnly ?? this.firstOrderOnly,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
