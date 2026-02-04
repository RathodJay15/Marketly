import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _cartRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  // ─────────────────────────────────────────────
  // REALTIME CART STREAM
  // ─────────────────────────────────────────────
  Stream<List<CartItemModel>> cartStream(String uid) {
    return _cartRef(uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  // ─────────────────────────────────────────────
  // ADD TO CART (SAFE TOTAL CALCULATION)
  // ─────────────────────────────────────────────
  Future<void> addToCart({
    required String uid,
    required CartItemModel item,
  }) async {
    final query = await _cartRef(uid)
        .where('title', isEqualTo: item.title) // or productId if you add it
        .limit(1)
        .get();

    // If item already exists → increase quantity
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final existing = CartItemModel.fromFirestore(doc.data(), doc.id);

      final updated = existing.copyWithQuantity(existing.quantity + 1);

      await doc.reference.update(updated.toFirestore());
    } else {
      // Fresh item → ensure totals are correct
      final safeItem = item.copyWithQuantity(item.quantity);
      await _cartRef(uid).add(safeItem.toFirestore());
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE QUANTITY (SAFE)
  // ─────────────────────────────────────────────
  Future<void> updateQuantity({
    required String uid,
    required String cartItemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      await removeItem(uid, cartItemId);
      return;
    }

    final docRef = _cartRef(uid).doc(cartItemId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final existing = CartItemModel.fromFirestore(snapshot.data()!, snapshot.id);

    final updated = existing.copyWithQuantity(quantity);
    await docRef.update(updated.toFirestore());
  }

  // ─────────────────────────────────────────────
  // REMOVE ITEM
  // ─────────────────────────────────────────────
  Future<void> removeItem(String uid, String cartItemId) async {
    await _cartRef(uid).doc(cartItemId).delete();
  }

  // ─────────────────────────────────────────────
  // CLEAR CART
  // ─────────────────────────────────────────────
  Future<void> clearCart(String uid) async {
    final snapshot = await _cartRef(uid).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
