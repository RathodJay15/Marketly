import 'cart_item_model.dart';

class CartModel {
  final String id;
  final List<CartItemModel> products;
  final double total;
  final double discountedTotal;
  final String userId;
  final int totalProducts;
  final int totalQuantity;

  CartModel({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory CartModel.fromFirestore(Map<String, dynamic> map, String id) {
    return CartModel(
      id: id,
      products: (map['products'] as List)
          .map((e) => CartItemModel.fromMap(e))
          .toList(),
      total: (map['total'] as num).toDouble(),
      discountedTotal: (map['discountedTotal'] as num).toDouble(),
      userId: map['userId'],
      totalProducts: map['totalProducts'],
      totalQuantity: map['totalQuantity'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'products': products.map((e) => e.toMap()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}
