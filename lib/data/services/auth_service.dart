import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ------------------------------------------------------------
  // Get user profile
  // ------------------------------------------------------------
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc.data()!, uid);
    } catch (e) {
      throw Exception('Failed to load user profile');
    }
  }

  // ------------------------------------------------------------
  // Login
  // ------------------------------------------------------------
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) return null;
      return await getUserProfile(result.user!.uid);
    } on FirebaseAuthException catch (_) {
      throw Exception('Invalid email or password');
    }
  }

  // ------------------------------------------------------------
  // Register
  // ------------------------------------------------------------
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String address,
    required String profilePic,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      final defaultAddress = [
        {
          "id": DateTime.now().millisecondsSinceEpoch.toString(),
          "address": address,
          "isDefault": true,
        },
      ];

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        role: 'user',
        profilePic: profilePic,
        addresses: defaultAddress,
        themeMode: 'system',
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      throw Exception('Registration failed');
    }
  }

  // ------------------------------------------------------------
  // Add new address
  // ------------------------------------------------------------
  Future<void> addAddress({
    required String uid,
    required String address,
    bool setAsDefault = false,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    if (setAsDefault) {
      for (final a in addresses) {
        a['isDefault'] = false;
      }
    }

    addresses.add({
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "address": address,
      "isDefault": setAsDefault,
    });

    await userRef.update({"addresses": addresses});
  }

  // ------------------------------------------------------------
  // Update address text
  // ------------------------------------------------------------
  Future<void> updateAddress({
    required String uid,
    required String addressId,
    required String newAddress,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    final index = addresses.indexWhere((a) => a['id'] == addressId);
    if (index == -1) return;

    addresses[index]['address'] = newAddress;

    await userRef.update({"addresses": addresses});
  }

  // ------------------------------------------------------------
  // Set default address
  // ------------------------------------------------------------
  Future<void> setDefaultAddress({
    required String uid,
    required String addressId,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    for (final addr in addresses) {
      addr['isDefault'] = addr['id'] == addressId;
    }

    await userRef.update({"addresses": addresses});
  }

  Future<void> unsetDefaultAddress(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    for (final addr in addresses) {
      addr['isDefault'] = false;
    }

    await userRef.update({"addresses": addresses});
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
