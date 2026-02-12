import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Fetch all products
  Future<List<ProductModel>> getAllProducts({int? limit}) async {
    Query query = _firestore.collection(_collection);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map(
          (doc) => ProductModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  // Fetch products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // Add new product
  Future<DocumentReference> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required double discount,
    required double rating,
    required int stock,
    required List<String> tags,
    required String brand,
    required double weight,
    required Map<String, double> dimensions,
  }) async {
    try {
      final docRef = _firestore.collection(_collection).doc();

      await docRef.set({
        'id': docRef.id,
        'title': title,
        'description': description,
        'category': category,
        'price': price,
        'discount': discount,
        'rating': rating,
        'stock': stock,
        'tags': tags,
        'brand': brand,
        'weight': weight,
        'dimensions': dimensions,
        'thumbnail': null,
        'images': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef;
    } catch (e) {
      throw Exception("Failed to create product: $e");
    }
  }

  // Update product
  Future<void> updateProduct(String productId, ProductModel product) async {
    await _firestore
        .collection(_collection)
        .doc(productId)
        .update(product.toFirestore());
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection(_collection).doc(productId).delete();
  }

  // Stream all products (real-time)
  Stream<List<ProductModel>> streamAllProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Stream products by category (real-time)
  Stream<List<ProductModel>> streamProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}
