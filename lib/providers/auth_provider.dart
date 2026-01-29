import 'package:flutter/material.dart';
import 'package:marketly/controllers/auth_controller.dart';
import 'package:marketly/data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _authController;

  AuthProvider(this._authController);

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authController.login(email: email, password: password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // REGISTER
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authController.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _authController.logout();
    _user = null;
    notifyListeners();
  }

  // AUTO LOGIN (on app start)
  Future<void> loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stream = _authController.authStateChanges();
      stream.listen((firebaseUser) async {
        if (firebaseUser == null) {
          _user = null;
        } else {
          _user = await _authController.getUserProfile(firebaseUser.uid);
        }
        notifyListeners();
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
