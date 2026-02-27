import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class CartModel {
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final List<CartItemModel> items;

  CartModel({
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    required this.isExpired,
    required this.items,
  });

  factory CartModel.fromFirestore(
    Map<String, dynamic> map,
    String userId,
    List<CartItemModel> items,
  ) {
    return CartModel(
      userId: userId,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isExpired: map['isExpired'] ?? false,
      items: items,
    );
  }

  bool get hasExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
