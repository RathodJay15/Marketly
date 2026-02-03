import 'package:flutter/material.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/data/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _homeProducts = [];
  List<ProductModel> _allProducts = [];

  List<ProductModel> get homeProducts => _homeProducts;
  List<ProductModel> get allProducts => _allProducts;

  // State
  List<ProductModel> get products => _allProducts;
  List<ProductModel> get tenProducts => _homeProducts;

  bool _isHomeLoading = false;
  bool _isSearchLoading = false;

  bool get isHomeLoading => _isHomeLoading;
  bool get isSearchLoading => _isSearchLoading;

  String? _error;
  String? get error => _error;

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
      _allProducts = await _productService.getProductsByCategory(categorySlug);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isSearchLoading = false;
      notifyListeners();
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
