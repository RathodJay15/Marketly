import 'package:flutter/foundation.dart';
import 'package:marketly/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  void setUser(UserModel user) {
    if (_user?.uid == user.uid) return;
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    if (_user == null) return;
    _user = null;
    notifyListeners();
  }
}
