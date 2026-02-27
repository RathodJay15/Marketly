import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> likeProduct(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_products')
        .doc(productId)
        .set({'productId': productId, 'likedAt': FieldValue.serverTimestamp()});
  }

  Future<void> unlikeProduct(String userId, String productId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_products')
        .doc(productId)
        .delete();
  }

  Stream<List<String>> getLikedProductIds(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('liked_products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
