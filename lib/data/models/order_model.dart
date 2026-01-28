import 'package:marketly/data/models/cart_model.dart';

class OrderModel {
  final String? orderId;
  final String? userId;
  final List<CartModel> items;
  final double? totalAmount;
  final String? status; // Pending | Shipped | Delivered

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      userId: map['userId'] ?? '',
      items: (map['items'] as List).map((e) => CartModel.fromMap(e)).toList(),
      totalAmount: (map['totalAmount'] ?? 0.0 as num).toDouble(),
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
    };
  }
}
