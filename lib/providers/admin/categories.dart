import 'package:flutter/material.dart';
import 'package:marketly/data/models/category_model.dart';
import 'package:marketly/data/services/category_service.dart';

class AdminCategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ------------------------------------------------------------
  // Fetch All Categories (Admin View)
  // ------------------------------------------------------------
  Future<void> fetchAllCategories() async {
    try {
      _setLoading(true);
      _categories = await _categoryService.getAllCategories();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Add Category
  // ------------------------------------------------------------
  Future<bool> addCategory({
    required String slug,
    required String title,
  }) async {
    try {
      _setLoading(true);

      await _categoryService.addCategory(slug: slug, title: title);

      await fetchAllCategories(); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // Activate / Deactivate Category
  // ------------------------------------------------------------
  Future<void> toggleCategoryStatus({
    required String slug,
    required bool isActive,
  }) async {
    try {
      await _categoryService.updateCategoryActiveState(
        slug: slug,
        isActive: isActive,
      );

      final index = _categories.indexWhere((category) => category.slug == slug);

      if (index != -1) {
        _categories[index] = _categories[index].copyWith(isActive: isActive);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // Delete Category
  // ------------------------------------------------------------
  Future<void> deleteCategory(String slug) async {
    try {
      await _categoryService.deleteCategory(slug);

      _categories.removeWhere((category) => category.slug == slug);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ------------------------------------------------------------
  // Private Loading Setter
  // ------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
