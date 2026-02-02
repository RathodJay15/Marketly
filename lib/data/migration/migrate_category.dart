import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> migrateCategoriesToFirebase() async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/categories'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch categories');
    }

    //  Correct decode
    final List<dynamic> decoded = json.decode(response.body);

    final batch = _firestore.batch();

    for (int i = 0; i < decoded.length; i++) {
      final Map<String, dynamic> category = decoded[i] as Map<String, dynamic>;

      final String slug = category['slug'];
      final String title = category['name'];

      final docRef = _firestore.collection('categories').doc(slug);

      batch.set(docRef, {
        'slug': slug,
        'title': title,
        'isActive': true,
        'order': i + 1,
      });
    }

    await batch.commit();
    print('✅ Categories migrated successfully');
  }
}
