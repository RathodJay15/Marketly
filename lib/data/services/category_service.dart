import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  /// Get all active categories (for users)
  Future<List<CategoryModel>> getActiveCategories() async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  /// Get all categories (admin view)
  Future<List<CategoryModel>> getAllCategories() async {
    final snapshot = await _firestore.collection(_collection).get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList();
  }

  // Add new category (for admin)

  Future<void> addCategory({
    required String slug,
    required String title,
    required bool isActive,
  }) async {
    final collectionRef = _firestore.collection(_collection);
    final docRef = collectionRef.doc(slug);

    // Check if category already exists
    final exists = await docRef.get();
    if (exists.exists) {
      throw Exception('Category already exists');
    }

    // Get highest order
    final lastCategorySnapshot = await collectionRef
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    int nextOrder = 0;
    if (lastCategorySnapshot.docs.isNotEmpty) {
      nextOrder = (lastCategorySnapshot.docs.first['order'] as int) + 1;
    }

    // Add category with next order
    await docRef.set({
      'slug': slug,
      'title': title,
      'isActive': isActive,
      'order': nextOrder,
    });
  }

  /// Update full category (title, slug, active state)
  Future<void> updateCategory({
    required String oldSlug,
    required String slug,
    required String title,
    required bool isActive,
  }) async {
    final collectionRef = _firestore.collection(_collection);

    // If slug changed → we must rename document
    if (oldSlug != slug) {
      final oldDoc = await collectionRef.doc(oldSlug).get();

      if (!oldDoc.exists) {
        throw Exception("Category not found");
      }

      // Check if new slug already exists
      final newDocCheck = await collectionRef.doc(slug).get();
      if (newDocCheck.exists) {
        throw Exception("Slug already exists");
      }

      final oldData = oldDoc.data()!;

      // Create new doc with updated data
      await collectionRef.doc(slug).set({
        ...oldData,
        'slug': slug,
        'title': title,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete old document
      await collectionRef.doc(oldSlug).delete();
    } else {
      // If slug not changed → simple update
      await collectionRef.doc(slug).update({
        'title': title,
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update active state

  Future<void> updateCategoryActiveState({
    required String slug,
    required bool isActive,
  }) async {
    await _firestore.collection(_collection).doc(slug).update({
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete category

  Future<void> deleteCategory(String slug) async {
    await _firestore.collection(_collection).doc(slug).delete();
  }
}
