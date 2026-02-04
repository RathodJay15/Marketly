import 'package:marketly/data/models/cart_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartModel> items;
  final double totalAmount;
  final String status; // Pending | Shipped | Delivered

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
  });

  // factory OrderModel.fromFirestore(Map<String, dynamic> doc, String id) {
  //   return OrderModel(
  //     orderId: id,
  //     userId: doc['userId'] ?? '',
  //     items: (doc['items'] as List)
  //         .map((e) => CartModel.fromFirestore(e))
  //         .toList(),
  //     totalAmount: (doc['totalAmount'] ?? 0.0 as num).toDouble(),
  //     status: doc['status'] ?? '',
  //   );
  // }

  // Map<String, dynamic> toFirestore() {
  //   return {
  //     'userId': userId,
  //     'items': items.map((e) => e.toFirestore()).toList(),
  //     'totalAmount': totalAmount,
  //     'status': status,
  //   };
  // }
}
