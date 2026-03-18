import 'package:marketly/data/models/address_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<AddressModel> addresses;
  final String phone;

  final String? profilePic;
  final String themeMode;
  final List<String>? fcmToken;
  final String role; // 'admin' or 'user'
  final bool isDeleted;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.addresses,
    required this.profilePic,
    required this.themeMode,
    this.isDeleted = false,
    this.fcmToken,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'],
      email: map['email'],
      addresses: (map['addresses'] as List<dynamic>? ?? [])
          .map((a) => AddressModel.fromMap(Map<String, dynamic>.from(a)))
          .toList(),

      phone: map['phone'],
      profilePic: map['profilePic'],
      role: map['role'],
      themeMode: map['themeMode'] ?? 'system',
      isDeleted: map['isDeleted'] ?? false,
      fcmToken: (map['fcmToken'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'phone': phone,
      'role': role,
      'profilePic': profilePic,
      'themeMode': themeMode,
      'isDeleted': isDeleted,
      'fcmToken': fcmToken,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    List<AddressModel>? addresses,
    String? phone,
    String? profilePic,
    String? role,
    String? themeMode,
    bool? isDeleted,
    List<String>? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      themeMode: themeMode ?? this.themeMode,
      isDeleted: isDeleted ?? this.isDeleted,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
