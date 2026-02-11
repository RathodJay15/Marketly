import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';

class AllProducts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _allProductsState();
}

class _allProductsState extends State<AllProducts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppConstants.products,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Text(AppConstants.products),
    );
  }
}
