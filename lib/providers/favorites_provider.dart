import 'dart:async';
import 'package:flutter/material.dart';
import 'package:marketly/data/services/favorites_services.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesServices _service = FavoritesServices();

  StreamSubscription? _subscription;

  Set<String> _likedProductIds = {};

  Set<String> get likedProductIds => _likedProductIds;

  void listenToLikes(String userId) {
    _subscription?.cancel();
    _subscription = _service.getLikedProductIds(userId).listen((ids) {
      _likedProductIds = ids.toSet();
      notifyListeners();
    });
  }

  void stopListening() {
    _subscription?.cancel();
    _likedProductIds.clear();
  }

  Future<void> toggleLike(String userId, String productId) async {
    if (_likedProductIds.contains(productId)) {
      await _service.unlikeProduct(userId, productId);
    } else {
      await _service.likeProduct(userId, productId);
    }
  }

  bool isLiked(String productId) {
    return _likedProductIds.contains(productId);
  }
}
