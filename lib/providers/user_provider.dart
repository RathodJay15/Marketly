import 'package:flutter/material.dart';
import 'package:marketly/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  ThemeMode get themeMode {
    switch (_user?.themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  void setUser(UserModel user) {
    _isLoading = false;
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    if (_user == null) return;
    _user = null;
    _isLoading = false;
  }
}
