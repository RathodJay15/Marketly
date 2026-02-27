import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const int _cartExpiryMinutes = 30;

  // ─────────────────────────────────────────────
  // CART DOCUMENT REFERENCE (metadata)
  // ─────────────────────────────────────────────
  DocumentReference<Map<String, dynamic>> _cartDocRef(String uid) {
    return _firestore.collection('cart').doc(uid);
  }

  // ─────────────────────────────────────────────
  // CART ITEMS SUBCOLLECTION
  // ─────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _cartItemsRef(String uid) {
    return _cartDocRef(uid).collection('cartItems');
  }

  // ─────────────────────────────────────────────
  // REALTIME CART STREAM (Items Only For Now)
  // ─────────────────────────────────────────────
  Stream<List<CartItemModel>> cartStream(String uid) {
    return _cartItemsRef(uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  // ─────────────────────────────────────────────
  // ADD TO CART
  // ─────────────────────────────────────────────
  Future<void> addToCart({
    required String uid,
    required CartItemModel item,
  }) async {
    await _ensureCartDocument(uid);

    final query = await _cartItemsRef(
      uid,
    ).where('productId', isEqualTo: item.productId).limit(1).get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final existing = CartItemModel.fromFirestore(doc.data(), doc.id);
      final updated = existing.copyWithQuantity(existing.quantity + 1);
      await doc.reference.update(updated.toFirestore());
    } else {
      final safeItem = item.copyWithQuantity(item.quantity);
      await _cartItemsRef(uid).add(safeItem.toFirestore());
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE QUANTITY
  // ─────────────────────────────────────────────
  Future<void> updateQuantity({
    required String uid,
    required String cartItemId,
    required int quantity,
  }) async {
    await _ensureCartDocument(uid);

    if (quantity <= 0) {
      await removeItem(uid, cartItemId);
      return;
    }

    final docRef = _cartItemsRef(uid).doc(cartItemId);
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
    await _ensureCartDocument(uid);
    await _cartItemsRef(uid).doc(cartItemId).delete();
  }

  // ─────────────────────────────────────────────
  // CLEAR CART
  // ─────────────────────────────────────────────
  Future<void> clearCart(String uid) async {
    await _ensureCartDocument(uid);
    final snapshot = await _cartItemsRef(uid).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    await _cartDocRef(uid).delete();
  }

  //─────────────────────────────────────────────
  //
  //─────────────────────────────────────────────
  Future<void> _ensureCartDocument(String uid) async {
    final docRef = _cartDocRef(uid);
    final snapshot = await docRef.get();

    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(const Duration(minutes: 30)),
    );

    if (!snapshot.exists) {
      await docRef.set({
        'createdAt': now,
        'updatedAt': now,
        'expiresAt': expiresAt,
        'isExpired': false,
      });
    } else {
      await docRef.update({
        'updatedAt': now,
        'expiresAt': expiresAt,
        'isExpired': false,
      });
    }
  }
}
