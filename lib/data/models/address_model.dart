class AddressModel {
  final String id;
  final String label;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String recipientName;
  final String recipientPhone;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.address,
    required this.city,
    required this.country,
    required this.state,
    required this.pincode,
    required this.recipientName,
    required this.recipientPhone,
    required this.isDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'isDefault': isDefault,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      address: map['address'] ?? '',
      city: map['city'],
      country: map['country'],
      pincode: map['pincode'],
      state: map['state'],
      recipientName: map['recipientName'] ?? '',
      recipientPhone: map['recipientPhone'] ?? '',
      isDefault: map['isDefault'] ?? false,
    );
  }
  AddressModel copyWith({
    String? id,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? label,
    String? recipientName,
    String? recipientPhone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
