import 'package:flutter/material.dart';
import 'package:marketly/data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;
  const CategoryChips({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ChoiceChip(
        label: Text(
          category.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        selected: isSelected,
        selectedColor: Theme.of(context).colorScheme.onInverseSurface,
        backgroundColor: Theme.of(context).colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
