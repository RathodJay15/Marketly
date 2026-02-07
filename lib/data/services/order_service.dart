import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(OrderModel order) async {
    final doc = _firestore.collection('orders').doc();

    await doc.set(order.copyWith(id: doc.id).toFirestore());
  }

  Future<List<OrderModel>> getOrders(String userId) async {
    final snap = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((d) => OrderModel.fromFirestore(d.data(), d.id))
        .toList();
  }
}
