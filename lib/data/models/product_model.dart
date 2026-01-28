class ProductModel {
  final String? id;
  final String? name;
  final double? price;
  final String? description;
  final String? categoryId;
  final List<String>? images;
  final int? stock;
  final double? rating;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    required this.images,
    required this.stock,
    required this.rating,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0 as num).toDouble(),
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      images: List<String>.from(map['images'] ?? ''),
      stock: map['stock'] ?? 0,
      rating: (map['rating'] ?? 0.0 as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'categoryId': categoryId,
      'images': images,
      'stock': stock,
      'rating': rating,
    };
  }
}
