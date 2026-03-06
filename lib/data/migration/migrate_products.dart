import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

// class ProductMigrationService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> migrateProducts() async {
//     final url = Uri.parse('https://dummyjson.com/products?limit=100');

//     final response = await http.get(url);

//     if (response.statusCode != 200) {
//       throw Exception('Failed to fetch products');
//     }

//     final decoded = jsonDecode(response.body);
//     final List products = decoded['products'];

//     for (final item in products) {
//       final product = ProductModel.fromFirestore(item, '');

//       await _firestore.collection('products').add(product.toFirestore());
//     }

//     print('✅ Product migration completed successfully');
//   }
// }
class ProductMigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double usdToInr = 83.0;

  Future<void> migrateProducts() async {
    final url = Uri.parse('https://dummyjson.com/products?limit=100');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products');
    }

    final decoded = jsonDecode(response.body);
    final List products = decoded['products'];

    for (final item in products) {
      final product = ProductModel.fromFirestore(item, '');

      // Convert USD → INR
      final convertedPrice = product.price * usdToInr;

      await _firestore.collection('products').add({
        ...product.toFirestore(),
        'price': convertedPrice,
      });
    }

    print('✅ Product migration completed successfully');
  }
}
