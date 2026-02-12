import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/admin/crud_category/add_category.dart';
import 'package:marketly/presentation/admin/crud_category/edit_category.dart';
import 'package:marketly/providers/admin/admin_categories_provider.dart';
import 'package:provider/provider.dart';

class AllCategories extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _allCategoriesState();
}

class _allCategoriesState extends State<AllCategories> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCategoryProvider>().fetchAllCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.categories,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<AdminCategoryProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              );
            }

            return ListView.builder(
              itemCount: provider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddCategory()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.addCategory,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final category = provider.categories[index - 1];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: ListTile(
                    leading: Text(
                      index.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontSize: 25,
                      ),
                    ),
                    title: Text(
                      category.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      category.isActive
                          ? AppConstants.active
                          : AppConstants.inActive,
                      style: TextStyle(
                        color: category.isActive
                            ? Theme.of(context).colorScheme.onSecondary
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditCategory(category: category),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.edit),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
