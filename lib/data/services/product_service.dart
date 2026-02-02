import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Fetch all products
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _firestore.collection(_collection).get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  }

  // Fetch products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromJson(doc.data()))
        .toList();
  }

  // Add new product
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection(_collection).add(product.toFirestore());
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
              .map((doc) => ProductModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// 🔹 Stream products by category (real-time)
  Stream<List<ProductModel>> streamProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
