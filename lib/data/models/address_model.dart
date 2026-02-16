class AddressModel {
  final String id;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.address,
    required this.isDefault,
  });
  Map<String, dynamic> toMap() {
    return {'id': id, 'address': address, 'isDefault': isDefault};
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      address: map['address'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
  AddressModel copyWith({String? id, String? address, bool? isDefault}) {
    return AddressModel(
      id: id ?? this.id,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
