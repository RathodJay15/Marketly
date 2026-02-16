import 'package:marketly/data/models/address_model.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<AddressModel> addresses;
  final String phone;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String? profilePic;
  final String themeMode;
  final String role; // 'admin' or 'user'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.addresses,
    required this.profilePic,
    required this.city,
    required this.country,
    required this.state,
    required this.pincode,
    required this.themeMode,
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
      city: map['city'],
      country: map['country'],
      pincode: map['pincode'],
      state: map['state'],
      profilePic: map['profilePic'],
      role: map['role'],
      themeMode: map['themeMode'] ?? 'system',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'addresses': addresses.map((a) => a.toMap()).toList(),
      'phone': phone,
      'role': role,
      'state': state,
      'city': city,
      'country': country,
      'pincode': pincode,
      'profilePic': profilePic,
      'themeMode': themeMode,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    List<AddressModel>? addresses,
    String? phone,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? profilePic,
    String? role,
    String? themeMode,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      addresses: addresses ?? this.addresses,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      profilePic: profilePic ?? this.profilePic,
      role: role ?? this.role,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
