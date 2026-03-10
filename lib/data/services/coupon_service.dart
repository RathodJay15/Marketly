import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/models/coupon_model.dart';

class CouponServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CouponModel?> getCoupon(String code) async {
    final doc = await _firestore.collection('coupons').doc(code).get();

    if (!doc.exists) return null;

    return CouponModel.fromFirestore(doc);
  }

  Future<List<CouponModel>> getAllCoupons() async {
    final snapshot = await _firestore.collection('coupons').get();

    return snapshot.docs.map((doc) => CouponModel.fromFirestore(doc)).toList();
  }

  Future<bool> hasUserUsedCoupon(String userId, String couponCode) async {
    final doc = await _firestore
        .collection('coupon_usage')
        .doc("${userId}_$couponCode")
        .get();

    return doc.exists;
  }

  Future<void> saveCouponUsage({
    required String userId,
    required String couponCode,
    required String orderNumber,
  }) async {
    await _firestore
        .collection('coupon_usage')
        .doc("${userId}_$couponCode")
        .set({
          "userId": userId,
          "couponCode": couponCode,
          "orderNumber": orderNumber,
          "usedAt": FieldValue.serverTimestamp(),
        });
  }

  // New coupon (for admin)
  Future<void> addCoupon({
    required String code,
    required int discountPercentage,
    required bool isActive,
    required bool firstOrderOnly,
    required int expiriesInDays,
    required double minOrderAmount,
  }) async {
    final collectionRef = _firestore.collection('coupons');
    final docRef = collectionRef.doc(code);

    // Check if category already exists
    final exists = await docRef.get();
    if (exists.exists) {
      throw Exception('Coupon already exists');
    }

    // Add category with next order
    await docRef.set({
      'code': code,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'firstOrderOnly': firstOrderOnly,
      'minOrderAmount': minOrderAmount,
      'createdAt': FieldValue.serverTimestamp(),
      'expiryDate': Timestamp.fromDate(
        DateTime.now().add(Duration(days: expiriesInDays)),
      ),
    });
  }

  /// Update full coupon
  Future<void> updateCoupon({
    required String oldCode,
    required String code,
    required int discountPercentage,
    required bool isActive,
    required bool firstOrderOnly,
    required int expiriesInDays,
    required int minOrderAmount,
  }) async {
    final collectionRef = _firestore.collection('coupons');

    // If slug changed → we must rename document
    if (oldCode != code) {
      final oldDoc = await collectionRef.doc(oldCode).get();

      if (!oldDoc.exists) {
        throw Exception("Coupon not found");
      }

      // Check if new slug already exists
      final newDocCheck = await collectionRef.doc(code).get();
      if (newDocCheck.exists) {
        throw Exception("Coupon code already exists");
      }

      final oldData = oldDoc.data()!;

      // Create new doc with updated data
      await collectionRef.doc(code).set({
        ...oldData,
        'code': code,
        'discountPercentage': discountPercentage,
        'isActive': isActive,
        'firstOrderOnly': firstOrderOnly,
        'minOrderAmount': minOrderAmount,
        'expiryDate': Timestamp.fromDate(
          DateTime.now().add(Duration(days: expiriesInDays)),
        ),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Delete old document
      await collectionRef.doc(oldCode).delete();
    } else {
      // If slug not changed → simple update
      await collectionRef.doc(code).update({
        'code': code,
        'discountPercentage': discountPercentage,
        'isActive': isActive,
        'firstOrderOnly': firstOrderOnly,
        'minOrderAmount': minOrderAmount,
        'expiryDate': Timestamp.fromDate(
          DateTime.now().add(Duration(days: expiriesInDays)),
        ),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateCouponActiveState({
    required String code,
    required bool isActive,
  }) async {
    await _firestore.collection('coupons').doc(code).update({
      'isActive': isActive,
    });
  }

  // Delete coupon

  Future<void> deleteCoupon(String code) async {
    await _firestore.collection('coupons').doc(code).delete();
  }

  //------------------------------------------------------------------------------

  Future<void> addDefaultCoupons() async {
    final batch = _firestore.batch();
    final collection = _firestore.collection('coupons');

    final coupons = [
      {
        "code": "FIRSTORDER100",
        "discountPercentage": 10,
        "minOrderAmount": 250,
      },
      {"code": "GET10FREE", "discountPercentage": 10, "minOrderAmount": 350},
      {"code": "500FFTODAY", "discountPercentage": 25, "minOrderAmount": 550},
      {"code": "MEGADISCOUNT", "discountPercentage": 50, "minOrderAmount": 750},
    ];

    for (var coupon in coupons) {
      final doc = collection.doc(coupon['code'] as String);

      batch.set(doc, {
        "code": coupon['code'],
        "discountPercentage": coupon['discountPercentage'],
        "minOrderAmount": coupon['minOrderAmount'],
        "isActive": true,
        "firstOrderOnly": true,
        "createdAt": FieldValue.serverTimestamp(),
        "expiryDate": Timestamp.fromDate(
          DateTime.now().add(Duration(days: 30)),
        ),
      });
    }

    await batch.commit();
  }
}
