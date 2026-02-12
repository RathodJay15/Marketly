import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ImageService {
  Future<String?> uploadProfileImage({
    required String uid,
    required File imageFile,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(uid);

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadProductThumbnail({
    required String productId,
    required File imageFile,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('products')
          .child(productId)
          .child('thumbnail.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // ---------------- PRODUCT MULTIPLE IMAGES ----------------
  Future<List<String>> uploadProductImages({
    required String productId,
    required List<File> imageFiles,
  }) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('products')
            .child(productId)
            .child('images')
            .child('image_$i.jpg');

        await ref.putFile(imageFiles[i]);

        final url = await ref.getDownloadURL();
        downloadUrls.add(url);
      }

      return downloadUrls;
    } catch (e) {
      return [];
    }
  }
}
