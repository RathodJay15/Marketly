class UserModel {
  final String? uid;
  final String? name;
  final String? email;
  final String? address;
  final String? phone;
  final String? profilePic;
  final String? role; // 'admin' or 'user'

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.address,
    required this.profilePic,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      profilePic: map['profilePic'] ?? '',
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'role': role,
      'profilePic': profilePic,
    };
  }
}
