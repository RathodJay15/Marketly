import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marketly/data/services/product_service.dart';
import '../models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProductService _productService = ProductService();
  static const int _cartExpiryMinutes = 60;

  // ---------------------------------------------
  // CART DOCUMENT REFERENCE (metadata)
  // ---------------------------------------------
  DocumentReference<Map<String, dynamic>> _cartDocRef(String uid) {
    return _firestore.collection('cart').doc(uid);
  }

  // ---------------------------------------------
  // CART ITEMS SUBCOLLECTION
  // ---------------------------------------------
  CollectionReference<Map<String, dynamic>> _cartItemsRef(String uid) {
    return _cartDocRef(uid).collection('cartItems');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> cartMetaStream(String uid) {
    return _cartDocRef(uid).snapshots();
  }

  // ---------------------------------------------
  // REALTIME CART STREAM (Items Only For Now)
  // ---------------------------------------------
  Stream<List<CartItemModel>> cartStream(String uid) {
    return _cartItemsRef(uid).snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => CartItemModel.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  // ---------------------------------------------
  // ADD TO CART
  // ---------------------------------------------
  Future<void> addToCart({
    required String uid,
    required CartItemModel item,
  }) async {
    await _ensureCartDocument(uid);

    final productRef = _firestore.collection('products').doc(item.productId);

    await _firestore.runTransaction((transaction) async {
      // Get product
      final productSnap = await transaction.get(productRef);

      if (!productSnap.exists) {
        throw Exception("Product not found");
      }

      final stock = productSnap['stock'];

      // Check existing cart item
      final query = await _cartItemsRef(
        uid,
      ).where('productId', isEqualTo: item.productId).limit(1).get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;

        final existing = CartItemModel.fromFirestore(doc.data(), doc.id);

        // Check stock for +1
        if (stock < item.quantity) {
          throw Exception("Out of stock");
        }

        // Reduce stock
        transaction.update(productRef, {'stock': stock - item.quantity});

        // Increase quantity
        final updated = existing.copyWithQuantity(
          existing.quantity + item.quantity,
        );

        transaction.update(doc.reference, updated.toFirestore());
      } else {
        // New item

        if (stock < item.quantity) {
          throw Exception("Out of stock");
        }

        // Reduce stock
        transaction.update(productRef, {'stock': stock - item.quantity});

        final newDoc = _cartItemsRef(uid).doc();
        transaction.set(newDoc, item.toFirestore());
      }
    });
  }

  // ---------------------------------------------
  // UPDATE QUANTITY
  // ---------------------------------------------
  Future<void> updateQuantity({
    required String uid,
    required String cartItemId,
    required int quantity,
  }) async {
    await _ensureCartDocument(uid);

    final cartRef = _cartItemsRef(uid).doc(cartItemId);

    await _firestore.runTransaction((transaction) async {
      final cartSnap = await transaction.get(cartRef);

      if (!cartSnap.exists) return;

      final existing = CartItemModel.fromFirestore(
        cartSnap.data()!,
        cartSnap.id,
      );

      final productRef = _firestore
          .collection('products')
          .doc(existing.productId);

      final productSnap = await transaction.get(productRef);

      if (!productSnap.exists) {
        throw Exception("Product not found");
      }

      final stock = productSnap['stock'];
      final currentQty = existing.quantity;

      final diff = quantity - currentQty;

      // INCREASE quantity
      if (diff > 0) {
        if (stock < diff) {
          throw Exception("Out of stock");
        }

        // reduce stock
        transaction.update(productRef, {'stock': stock - diff});
      }
      // DECREASE quantity
      else if (diff < 0) {
        final restoreQty = diff.abs();

        // restore stock
        transaction.update(productRef, {'stock': stock + restoreQty});
      }

      // update cart
      if (quantity <= 0) {
        transaction.delete(cartRef);
      } else {
        final updated = existing.copyWithQuantity(quantity);
        transaction.update(cartRef, updated.toFirestore());
      }
    });
  }

  // ---------------------------------------------
  // REMOVE ITEM
  // ---------------------------------------------
  Future<void> removeItem(String uid, String cartItemId) async {
    final cartRef = _cartItemsRef(uid).doc(cartItemId);

    await _firestore.runTransaction((transaction) async {
      final cartSnap = await transaction.get(cartRef);

      if (!cartSnap.exists) return;

      final item = CartItemModel.fromFirestore(cartSnap.data()!, cartSnap.id);

      final productRef = _firestore.collection('products').doc(item.productId);

      final productSnap = await transaction.get(productRef);

      if (!productSnap.exists) {
        throw Exception("Product not found");
      }

      final currentStock = productSnap['stock'];

      // restore stock
      transaction.update(productRef, {'stock': currentStock + item.quantity});

      // delete cart item
      transaction.delete(cartRef);
    });
  }

  // ---------------------------------------------
  // CLEAR CART
  // ---------------------------------------------
  Future<void> clearCart(String uid) async {
    final snapshot = await _cartItemsRef(uid).get();

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      final item = CartItemModel.fromFirestore(doc.data(), doc.id);

      final productRef = _firestore.collection('products').doc(item.productId);

      // Restore stock
      batch.update(productRef, {'stock': FieldValue.increment(item.quantity)});

      // Delete cart item
      batch.delete(doc.reference);
    }

    // Delete cart document (optional)
    batch.delete(_cartDocRef(uid));

    await batch.commit();
  }

  // ---------------------------------------------
  //
  // ---------------------------------------------
  Future<void> _ensureCartDocument(String uid) async {
    final docRef = _cartDocRef(uid);
    final snapshot = await docRef.get();

    final now = Timestamp.now();
    final expiresAt = Timestamp.fromDate(
      DateTime.now().add(Duration(minutes: _cartExpiryMinutes)),
    );

    if (!snapshot.exists) {
      await docRef.set({
        'createdAt': now,
        'updatedAt': now,
        'expiresAt': expiresAt,
        'isExpired': false,
        'notificationSent': false,
      });
    } else {
      await docRef.update({
        'updatedAt': now,
        'expiresAt': expiresAt,
        'isExpired': false,
        'notificationSent': false,
      });
    }
  }
}
