import 'package:flutter/material.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:marketly/data/services/auth_service.dart';

class AdminUserProvider extends ChangeNotifier {
  final AuthService _userService = AuthService();

  List<UserModel?> _users = [];
  List<UserModel?> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Get All Users
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedUsers = await _userService.getAllUser();
      _users = fetchedUsers;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
