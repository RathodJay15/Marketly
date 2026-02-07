import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String userId;

  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> address;
  final List<Map<String, dynamic>> items;

  final Map<String, dynamic> pricing;
  final String paymentMethod;

  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userInfo,
    required this.address,
    required this.items,
    required this.pricing,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  /// 🔁 copyWith
  OrderModel copyWith({
    String? id,
    String? userId,
    Map<String, dynamic>? userInfo,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? items,
    Map<String, dynamic>? pricing,
    String? paymentMethod,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      address: address ?? this.address,
      items: items ?? this.items,
      pricing: pricing ?? this.pricing,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      "userId": userId,
      "userInfo": userInfo,
      "address": address,
      "items": items,
      "pricing": pricing,
      "paymentMethod": paymentMethod,
      "status": status,
      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  // From Firestore
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      userId: data['userId'],
      userInfo: Map<String, dynamic>.from(data['userInfo']),
      address: Map<String, dynamic>.from(data['address']),
      items: List<Map<String, dynamic>>.from(data['items']),
      pricing: Map<String, dynamic>.from(data['pricing']),
      paymentMethod: data['paymentMethod'],
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
