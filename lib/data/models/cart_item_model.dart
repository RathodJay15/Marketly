import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id; // Firestore document ID (cartItemId)
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;
  final DateTime? addedAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
    this.addedAt,
  });

  // 🔽 Firestore → Model
  factory CartItemModel.fromFirestore(Map<String, dynamic> map, String id) {
    return CartItemModel(
      id: id,
      productId: map['productId'],
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      total: (map['total'] as num).toDouble(),
      discountPercentage: (map['discountPercentage'] as num).toDouble(),
      discountedTotal: (map['discountedTotal'] as num).toDouble(),
      thumbnail: map['thumbnail'],
      addedAt: map['addedAt'] != null
          ? (map['addedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // 🔼 Model → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  // 🧮 Helper to recalculate totals safely
  CartItemModel copyWithQuantity(int newQuantity) {
    final newTotal = price * newQuantity;
    final newDiscountedTotal = newTotal - (newTotal * discountPercentage / 100);

    return CartItemModel(
      id: id,
      productId: productId,
      title: title,
      price: price,
      quantity: newQuantity,
      total: newTotal,
      discountPercentage: discountPercentage,
      discountedTotal: newDiscountedTotal,
      thumbnail: thumbnail,
      addedAt: addedAt,
    );
  }
}
