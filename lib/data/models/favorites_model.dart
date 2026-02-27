import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesModel {
  final String productId;
  final DateTime likedAt;

  FavoritesModel({required this.productId, required this.likedAt});

  Map<String, dynamic> toMap() {
    return {'productId': productId, 'likedAt': likedAt};
  }

  factory FavoritesModel.fromMap(Map<String, dynamic> map) {
    return FavoritesModel(
      productId: map['productId'],
      likedAt: (map['likedAt'] as Timestamp).toDate(),
    );
  }
}
