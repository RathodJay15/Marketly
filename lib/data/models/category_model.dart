// models/category_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String slug;
  final String title;
  final bool isActive;
  final int order;

  CategoryModel({
    required this.slug,
    required this.title,
    required this.isActive,
    required this.order,
  });

  factory CategoryModel.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return CategoryModel(
      slug: data['slug'],
      title: data['title'],
      isActive: data['isActive'],
      order: data['order'],
    );
  }

  CategoryModel copyWith({
    String? slug,
    String? title,
    bool? isActive,
    int? order,
  }) {
    return CategoryModel(
      slug: slug ?? this.slug,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }
}
