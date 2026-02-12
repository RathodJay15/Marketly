import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(OrderModel order) async {
    final doc = _firestore.collection('orders').doc();
    final orderMeta = await generateOrderNumber();

    final finalOrder = order.copyWith(
      id: doc.id,
      orderNumber: orderMeta['orderNumber'],
      sequence: orderMeta['sequence'],
    );

    await doc.set(finalOrder.toFirestore());
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final snap = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    return snap.docs
        .map((d) => OrderModel.fromFirestore(d.data(), d.id))
        .toList();
  }

  // For admin
  Future<List<OrderModel>> getAllOrders() async {
    final snap = await _firestore.collection('orders').get();

    return snap.docs
        .map((d) => OrderModel.fromFirestore(d.data(), d.id))
        .toList();
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final docRef = _firestore.collection('orders').doc(orderId);

    final doc = await docRef.get();
    if (!doc.exists) throw Exception("Order not found");

    final data = doc.data()!;
    List<dynamic> timeline = data['statusTimeline'] ?? [];

    // Prevent duplicate status
    final alreadyExists = timeline.any(
      (element) => element['status'] == status,
    );

    if (alreadyExists) return;

    timeline.add({"status": status, "time": FieldValue.serverTimestamp()});

    await docRef.update({
      "statusTimeline": timeline,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>> generateOrderNumber() async {
    return _firestore.runTransaction((transaction) async {
      final counterRef = _firestore.collection('counters').doc('orders');
      final snapshot = await transaction.get(counterRef);

      int newNumber;

      if (!snapshot.exists) {
        newNumber = 1;
        transaction.set(counterRef, {'lastNumber': newNumber});
      } else {
        final lastNumber = snapshot.get('lastNumber') as int;
        newNumber = lastNumber + 1;
        transaction.update(counterRef, {'lastNumber': newNumber});
      }

      final year = DateTime.now().year;

      return {
        'orderNumber': 'ORD-$year-${newNumber.toString().padLeft(5, '0')}',
        'sequence': newNumber,
      };
    });
  }
}
