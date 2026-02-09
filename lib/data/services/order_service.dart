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
