class CartItemModel {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  CartItemModel({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  CartItemModel copyWith({
    int? quantity,
    double? total,
    double? discountedTotal,
  }) {
    return CartItemModel(
      id: id,
      title: title,
      price: price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      discountPercentage: discountPercentage,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      thumbnail: thumbnail,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'].toString(),
      title: map['title'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      total: (map['total'] as num).toDouble(),
      discountPercentage: (map['discountPercentage'] as num).toDouble(),
      discountedTotal: (map['discountedTotal'] as num).toDouble(),
      thumbnail: map['thumbnail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }
}
