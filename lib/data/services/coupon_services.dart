import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/models/coupon_model.dart';

class CouponServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CouponModel?> getCoupon(String code) async {
    final doc = await _firestore.collection('coupons').doc(code).get();

    if (!doc.exists) return null;

    return CouponModel.fromFirestore(doc);
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
