import '../data/models/user_model.dart';
import 'package:marketly/data/services/auth/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  // LOGIN
  Future<UserModel?> login({required String email, required String password}) {
    return _authService.login(email: email, password: password);
  }

  // REGISTER
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) {
    return _authService.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      address: address,
    );
  }

  // GET USER PROFILE
  Future<UserModel?> getUserProfile(String uid) {
    return _authService.getUserProfile(uid);
  }

  // LOGOUT
  Future<void> logout() {
    return _authService.logout();
  }

  // AUTH STATE
  Stream authStateChanges() {
    return _authService.authStateChanges;
  }
}
