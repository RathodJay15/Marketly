import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:marketly/data/models/address_model.dart';
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

      UserModel user = UserModel.fromFirestore(doc.data()!, uid);

      if (user.isDeleted) {
        throw FirebaseAuthException(
          code: 'account-deactivated',
          message: 'This account has been deactivated.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.message == 'This account has been deactivated.') {
        throw Exception('This account has been deleted.');
      }
    } catch (e) {
      throw Exception('Failed to load user profile');
    }
    return null;
  }

  //--------------------------------------------------------------
  //  get all users
  //--------------------------------------------------------------

  Future<List<UserModel?>> getAllUser() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      return snapshot.docs.map((doc) {
        return UserModel.fromFirestore(
          doc.data(),
          doc.id, // pass document id as uid
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load user list');
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

  // Future<UserModel?> login({
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     email = email.trim();

  //     // Check if account exists
  //     final snapshot = await _firestore
  //         .collection('users')
  //         .where('email', isEqualTo: email)
  //         .limit(1)
  //         .get();

  //     if (snapshot.docs.isEmpty) {
  //       throw Exception("Couldn't find your account. Please register.");
  //     }

  //     final result = await _firebaseAuth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password.trim(),
  //     );

  //     final user = result.user;
  //     if (user == null) return null;

  //     return await getUserProfile(user.uid);
  //   } on FirebaseAuthException catch (_) {
  //     throw Exception('Wrong password. Try again.');
  //   }
  // }

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

      List<AddressModel> defaultAddress = [
        AddressModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          label: 'Home',
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          recipientName: name,
          recipientPhone: phone,
          lat: 0.0,
          long: 0.0,
          isDefault: true,
        ),
      ];

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
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
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      debugPrint('Error in registration : $e.toString()');
      throw Exception('Registration failed');
    }
  }

  // ------------------------------------------------------------
  // Add new address
  // ------------------------------------------------------------
  Future<void> addAddressFull({
    required String uid,
    required AddressModel address,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    // Handle default
    if (address.isDefault == true) {
      for (final a in addresses) {
        a['isDefault'] = false;
      }
    }

    addresses.add(address.toMap());

    await userRef.update({"addresses": addresses});
  }

  // ------------------------------------------------------------
  // Update address text
  // ------------------------------------------------------------
  Future<void> updateAddressFull({
    required String uid,
    required AddressModel address,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    final index = addresses.indexWhere((a) => a['id'] == address.id);
    if (index == -1) return;

    addresses[index] = address.toMap();

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
  // Delete Address
  // ------------------------------------------------------------

  Future<void> deleteAddress({
    required String uid,
    required String addressId,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final doc = await userRef.get();

    final addresses = List<Map<String, dynamic>>.from(
      doc.data()?['addresses'] ?? [],
    );

    addresses.removeWhere((a) => a['id'] == addressId);

    // Handle default
    if (addresses.isNotEmpty && !addresses.any((a) => a['isDefault'] == true)) {
      addresses[0]['isDefault'] = true;
    }

    await userRef.update({"addresses": addresses});
  }

  // ------------------------------------------------------------
  // Logout
  // ------------------------------------------------------------
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  // ------------------------------------------------------------
  // Firebase Console Messaging Token
  // ------------------------------------------------------------

  Future<void> saveFcmToken(String uid, String token) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'fcmToken': FieldValue.arrayUnion([token]),
    });
  }
}
