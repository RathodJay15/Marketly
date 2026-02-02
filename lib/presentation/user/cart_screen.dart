import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final String? initialProductId;

  const CartScreen({super.key, this.initialProductId});
  @override
  State<StatefulWidget> createState() => _cartScreenState();
}

class _cartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Cart Screen : Product id: ${widget.initialProductId}'),
    );
  }
}
