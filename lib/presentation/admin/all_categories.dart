import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/admin/edit_category.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:marketly/providers/admin/categories.dart';
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
        padding: const EdgeInsets.only(left: 20),
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
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: ListTile(
                    leading: Text(
                      category.order.toString(),
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
                      category.slug,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditCategory(category: category),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(Icons.edit),
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                        Switch(
                          value: category.isActive,
                          activeColor: Theme.of(
                            context,
                          ).colorScheme.onInverseSurface,
                          inactiveThumbColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          inactiveTrackColor: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                          onChanged: (value) async {
                            provider.toggleCategoryStatus(
                              slug: category.slug,
                              isActive: value,
                            );
                            await context
                                .read<AdminDashboardProvider>()
                                .refreshDashboard();
                          },
                        ),
                      ],
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
