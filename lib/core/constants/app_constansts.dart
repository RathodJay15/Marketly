import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static const String welcomeMsg = "Hello, Welcome 👋";
  static const String searchProducts = "Search products..";
  static const String home = "Home";
  static const String search = "Search";
  static const String cart = "Cart";
  static const String cartProducts = "Cart Products";
  static const String menu = "Menu";
  static const String ourProducts = "Our Products";
  static const String seeAll = "See all";

  static String formatedDate(Timestamp timestamp) {
    final dateTime = timestamp.toDate();

    final date = DateFormat('d MMMM yyyy').format(dateTime);

    return date;
  }

  static String formatedTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final time = DateFormat('HH:mm').format(dateTime);
    return time;
  }
}
