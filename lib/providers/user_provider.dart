import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/data/models/address_model.dart';
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
    _user = null;
    _isLoading = false;
  }

  // ------------------------------------------------------------
  // ADD ADDRESS
  // ------------------------------------------------------------
  Future<void> addAddress(
    String label,
    String addressText,
    String recipientName,
    String recipientPhone,
  ) async {
    final user = _user!;

    final newAddress = AddressModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      address: addressText,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      isDefault: user.addresses.isEmpty,
    );

    await authService.addAddressFull(
      // 👈 FIXED SERVICE METHOD
      uid: user.uid,
      address: newAddress,
    );

    _user = user.copyWith(addresses: [...user.addresses, newAddress]);
    notifyListeners();
  }

  // ------------------------------------------------------------
  // UPDATE ADDRESS
  // ------------------------------------------------------------
  Future<void> updateAddress(AddressModel updatedAddress) async {
    final user = _user!;

    await authService.updateAddressFull(uid: user.uid, address: updatedAddress);

    _user = user.copyWith(
      addresses: user.addresses.map((a) {
        return a.id == updatedAddress.id ? updatedAddress : a;
      }).toList(),
    );

    notifyListeners();
  }

  // ------------------------------------------------------------
  // DELETE ADDRESS
  // ------------------------------------------------------------
  Future<void> deleteAddress(String id) async {
    final user = _user!;

    await authService.deleteAddress(uid: user.uid, addressId: id);

    final updated = user.addresses.where((a) => a.id != id).toList();

    if (updated.isNotEmpty && !updated.any((a) => a.isDefault)) {
      updated[0] = updated[0].copyWith(isDefault: true);
    }

    _user = user.copyWith(addresses: updated);
    notifyListeners();
  }

  // ------------------------------------------------------------
  // SET DEFAULT
  // ------------------------------------------------------------
  Future<void> setDefaultAddress(String id) async {
    final user = _user!;

    await authService.setDefaultAddress(uid: user.uid, addressId: id);

    _user = user.copyWith(
      addresses: user.addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList(),
    );

    notifyListeners();
  }
}
