import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/data/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _homeProducts = [];
  List<ProductModel> _allProducts = [];
  List<ProductModel> _visibleProducts = [];

  List<ProductModel> get visibleProducts => _visibleProducts;

  List<ProductModel> get homeProducts => _homeProducts;
  List<ProductModel> get allProducts => _allProducts;

  // State
  List<ProductModel> get tenProducts => _homeProducts;

  bool _isHomeLoading = false;
  bool _isSearchLoading = false;

  bool get isHomeLoading => _isHomeLoading;
  bool get isSearchLoading => _isSearchLoading;

  String? _error;
  String? get error => _error;
  bool get isSearching => _visibleProducts.length != _allProducts.length;

  // Fetch home products
  Future<void> fetchHomeProducts({int? limit}) async {
    _isHomeLoading = true;
    notifyListeners();

    try {
      _homeProducts = await _productService.getAllProducts(limit: limit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isHomeLoading = false;
      notifyListeners();
    }
  }

  // Fetch All products
  Future<void> fetchAllProducts() async {
    _isSearchLoading = true;
    notifyListeners();

    try {
      _allProducts = await _productService.getAllProducts();

      _visibleProducts = _allProducts;

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String categorySlug) async {
    _isSearchLoading = true;
    notifyListeners();

    try {
      _visibleProducts = _allProducts
          .where((p) => p.category == categorySlug)
          .toList();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  // Search Products
  void searchProducts(String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (words.isEmpty) {
      _visibleProducts = _allProducts;
      notifyListeners();
      return;
    }

    _visibleProducts = _allProducts.where((product) {
      final titleWords = product.title.toLowerCase().split(RegExp(r'\s+'));

      return words.every((word) => titleWords.contains(word));
    }).toList();

    notifyListeners();
  }

  void clearSearchResult() {
    _visibleProducts = _allProducts;
    notifyListeners();
  }

  // Add product
  Future<DocumentReference> createProduct({
    required String title,
    required String description,
    required String category,
    required double price,
    required double discountPercentage,
    required double rating,
    required int stock,
    required List<String> tags,
    required String brand,
    required double weight,
    required Map<String, double> dimensions,
  }) async {
    return await _productService.createProduct(
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      tags: tags,
      brand: brand,
      weight: weight,
      dimensions: dimensions,
    );
  }

  // Update product
  Future<void> updateProduct(String productId, ProductModel product) async {
    try {
      await _productService.updateProduct(productId, product);
      await fetchAllProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productService.deleteProduct(productId);
      _allProducts.removeWhere((p) => p == productId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
