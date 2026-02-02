import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/data/models/category_model.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: provider.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final CategoryModel category = provider.categories[index];
              final bool isSelected = provider.isSelected(category);
              return ChoiceChip(
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
                onSelected: (_) {
                  provider.selectCategory(category);
                },
              );
            },
          ),
        );
      },
    );
  }
}
