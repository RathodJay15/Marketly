import 'package:flutter/material.dart';
import 'package:marketly/data/models/category_model.dart';

class EditCategory extends StatefulWidget {
  final CategoryModel category;

  EditCategory({super.key, required this.category});
  @override
  State<StatefulWidget> createState() => _editCategoryState();
}

class _editCategoryState extends State<EditCategory> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(widget.category.title));
  }
}
