import 'package:flutter/material.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/data/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  // State
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Fetch all products
  Future<void> fetchAllProducts() async {
    _setLoading(true);
    try {
      _products = await _productService.getAllProducts();
      print('🔥 PRODUCTS COUNT: ${_products.length}');
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Fetch products by category
  Future<void> fetchProductsByCategory(String category) async {
    _setLoading(true);
    try {
      _products = await _productService.getProductsByCategory(category);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _productService.addProduct(product);
      await fetchAllProducts();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
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
      _products.removeWhere((p) => p == productId);
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

  // Internal loading handler
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
