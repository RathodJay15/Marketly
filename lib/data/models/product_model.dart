import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int? stock;
  final List<String>? tags;
  final String brand;
  final double weight;
  final Map<String, double> dimensions;
  final List<String> images;
  final String thumbnail;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    this.stock,
    this.tags,
    required this.brand,
    required this.weight,
    required this.dimensions,
    required this.images,
    required this.thumbnail,
  });
  String get searchableText {
    final tagText = (tags ?? []).join(' ');
    return '$title $tagText'.toLowerCase();
  }

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    final dimensionsJson = json['dimensions'] as Map<String, dynamic>?;

    return ProductModel(
      id: id,
      title: json['title'] as String? ?? 'NAN',
      description: json['description'] as String? ?? 'NAN',
      category: json['category'] as String? ?? 'NAN',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      brand: json['brand'] as String? ?? 'NAN',
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: {
        'width': (dimensionsJson?['width'] as num?)?.toDouble() ?? 0.0,
        'height': (dimensionsJson?['height'] as num?)?.toDouble() ?? 0.0,
        'depth': (dimensionsJson?['depth'] as num?)?.toDouble() ?? 0.0,
      },
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumbnail: json['thumbnail'] as String? ?? 'NAN',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      if (stock != null) 'stock': stock,
      if (tags != null) 'tags': tags,
      'brand': brand,
      'weight': weight,
      'dimensions': dimensions,
      'images': images,
      'thumbnail': thumbnail,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
