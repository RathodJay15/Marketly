import 'package:firebase_auth/firebase_auth.dart';
import 'package:marketly/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists || doc.data() == null) return null;

      return UserModel.fromMap(doc.data()!, uid);
    } catch (e) {
      throw Exception('Failed to load user profile');
    }
  }

  // login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;

      if (user == null) return null;

      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    } catch (e) {
      throw Exception('Somthing went wrong during login!!');
    }
  }

  // register
  Future<UserModel?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) return null;

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        phone: phone,
        address: address,
        role: 'user',
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    } catch (e) {
      throw Exception('Somthing went wrong during registration!!');
    }
  }

  // logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }
}
