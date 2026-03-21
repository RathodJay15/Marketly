import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_helpers.dart';
import 'package:marketly/core/data_instance/auth_locator.dart';
import 'package:marketly/data/models/address_model.dart';
import 'package:marketly/data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final Map<String, Map<String, List<String>>> data = AppHelpers.locationData;

  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  List<String> get countries => data.keys.toList();

  // Get States based on Country
  List<String> get states {
    if (selectedCountry == null) return [];
    return data[selectedCountry!]!.keys.toList();
  }

  // Get Cities based on State
  List<String> get cities {
    if (selectedCountry == null || selectedState == null) return [];
    return data[selectedCountry!]![selectedState!]!;
  }

  //----------------------------------------------------------------------------

  List<String> _addressLabel = ["Home", "Work", "Friends", "Family", "Other"];
  String? _selectedLabel;

  String? get selectedLabel => _selectedLabel;

  UserModel? _user;
  bool _isLoading = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  List<String> get addressLabel => _addressLabel;

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
  Future<void> addAddress(AddressModel newAddress) async {
    final user = _user!;

    await authService.addAddressFull(uid: user.uid, address: newAddress);

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

  //---------------------------------------------------------------------------
  // label logic
  //---------------------------------------------------------------------------
  // Select label
  void selectLabel(String? label) {
    if (_selectedLabel == label) {
      // deselect if same chip tapped again
      _selectedLabel = null;
    } else {
      _selectedLabel = label;
    }
    notifyListeners();
  }

  void clearLblSelection() {
    _selectedLabel = null;
    // notifyListeners();
  }

  bool isSelected(String label) {
    return _selectedLabel == label;
  }

  //---------------------------------------------------------------------------
  // Country, State, City logic
  //---------------------------------------------------------------------------
  // Select Country
  void selectCountry(String? country) {
    selectedCountry = country;

    // reset dependent fields
    selectedState = null;
    selectedCity = null;

    notifyListeners();
  }

  // Select State
  void selectState(String? state) {
    selectedState = state;

    // reset city
    selectedCity = null;

    notifyListeners();
  }

  // Select City
  void selectCity(String? city) {
    selectedCity = city;
    notifyListeners();
  }

  void clearLocation() {
    selectedCity = null;
    selectedState = null;
    selectedCountry = null;
  }
}
