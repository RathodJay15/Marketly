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

  String formattedDimensions() {
    return dimensions.entries.map((e) => '${e.key}: ${e.value}').join('  •  ');
  }

  String formattedTags() {
    return tags?.join(' • ') ?? 'No Tags';
  }

  factory ProductModel.fromFirestore(Map<String, dynamic> doc, String id) {
    final dimensionsJson = doc['dimensions'] as Map<String, dynamic>?;

    return ProductModel(
      id: id,
      title: doc['title'] as String? ?? 'NAN',
      description: doc['description'] as String? ?? 'NAN',
      category: doc['category'] as String? ?? 'NAN',
      price: (doc['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (doc['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
      stock: doc['stock'] as int?,
      tags: (doc['tags'] as List?)?.map((e) => e.toString()).toList(),
      brand: (doc['brand'] as String?)?.trim().isNotEmpty == true
          ? doc['brand'].toString()
          : 'NaN',
      weight: (doc['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: {
        'width': (dimensionsJson?['width'] as num?)?.toDouble() ?? 0.0,
        'height': (dimensionsJson?['height'] as num?)?.toDouble() ?? 0.0,
        'depth': (dimensionsJson?['depth'] as num?)?.toDouble() ?? 0.0,
      },
      images: (doc['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      thumbnail: doc['thumbnail'] as String? ?? 'NAN',
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
