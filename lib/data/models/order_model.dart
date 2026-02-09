class OrderModel {
  final String id;
  final String userId;
  final String orderNumber;
  final int sequence;

  final Map<String, dynamic> userInfo;
  final Map<String, dynamic> address;
  final List<Map<String, dynamic>> items;

  final Map<String, dynamic> pricing;
  final String paymentMethod;
  final List<Map<String, dynamic>> statusTimeline;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userInfo,
    required this.address,
    required this.items,
    required this.pricing,
    required this.paymentMethod,
    required this.statusTimeline,
    required this.orderNumber,
    required this.sequence,
  });
  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    int? sequence,
    String? userId,
    Map<String, dynamic>? userInfo,
    Map<String, dynamic>? address,
    List<Map<String, dynamic>>? items,
    Map<String, dynamic>? pricing,
    String? paymentMethod,
    List<Map<String, dynamic>>? statusTimeline,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      sequence: sequence ?? this.sequence,
      userId: userId ?? this.userId,
      userInfo: userInfo ?? this.userInfo,
      address: address ?? this.address,
      items: items ?? this.items,
      pricing: pricing ?? this.pricing,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      statusTimeline: statusTimeline ?? this.statusTimeline,
    );
  }

  // ---------------------------------------------------------------------------
  // Firestore serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toFirestore() {
    return {
      "orderNumber": orderNumber,
      'sequence': sequence,
      "userId": userId,
      "userInfo": userInfo,
      "address": address,
      "items": items,
      "pricing": pricing,
      "paymentMethod": paymentMethod,
      "statusTimeline": statusTimeline,
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      orderNumber: data['orderNumber'],
      sequence: data['sequence'],
      userId: data['userId'] as String,
      userInfo: Map<String, dynamic>.from(data['userInfo'] ?? {}),
      address: Map<String, dynamic>.from(data['address'] ?? {}),
      items: List<Map<String, dynamic>>.from(
        (data['items'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
      pricing: Map<String, dynamic>.from(data['pricing'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? '',
      statusTimeline: List<Map<String, dynamic>>.from(
        (data['statusTimeline'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
    );
  }
}
