import 'package:flutter/material.dart';
import 'package:marketly/data/models/category_model.dart';
import 'package:marketly/data/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _service = CategoryService();

  String? selectedCategory;

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;

  // ---------------- GETTERS ----------------

  List<CategoryModel> get categories => _categories;

  // CategoryModel? get selectedCategory => _selectedCategory;

  String? get selectedCategorySlug => _selectedCategory?.slug;

  // ---------------- LOAD ----------------

  Future<void> loadCategories() async {
    _categories = await _service.getActiveCategories();
    notifyListeners();
  }

  // ---------------- UI calling ----------------

  void setCategory(String? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void selectCategory(CategoryModel category) {
    if (_selectedCategory?.slug == category.slug) {
      // deselect if same chip tapped again
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedCategory = null;
    notifyListeners();
  }

  bool isSelected(CategoryModel category) {
    return _selectedCategory?.slug == category.slug;
  }
}
