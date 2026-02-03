import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreenBody extends StatefulWidget {
  const HomeScreenBody({super.key});
  @override
  State<StatefulWidget> createState() => _homeScreenBodyState();
}

class _homeScreenBodyState extends State<HomeScreenBody> {
  final TextEditingController _textSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchHomeProducts(limit: 10);
    });
  }

  void onNavigation(index) {
    Provider.of<NavigationProvider>(
      context,
      listen: false,
    ).setScreenIndex(index);
  }

  void _startSearch() {
    onNavigation(1);
    setState(() => _isSearching = true);
  }

  void _onSearchPressed(value) async {
    onNavigation(1);
  }

  void _closeOrClearSearch() {
    if (_textSearchController.text.isNotEmpty) {
      _textSearchController.clear();
    } else {
      _searchFocusNode.unfocus();
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _textSearchController.dispose();
    _searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // pull to refresh API
        // await context.read<HomeController>().fetchHomeData();
      },
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildProfileCard(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSearchSection(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCategoryChips(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(AppConstants.ourProducts, 1),
          ),
          // const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProductCardList(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(AppConstants.cartProducts, 2),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: _buildCartList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.welcomeMsg,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              context.read<UserProvider>().user!.name ?? 'username',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          height: 40,
          width: 40,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return TextField(
      style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
      controller: _textSearchController,
      focusNode: _searchFocusNode,
      onTap: _startSearch,
      onSubmitted: (value) => _onSearchPressed(value),
      // enabled: false,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: AppConstants.searchProducts,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        fillColor: Theme.of(context).colorScheme.onSecondaryContainer,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                onPressed: _closeOrClearSearch,
              ),
            TextButton(
              onPressed: () => _onSearchPressed(_textSearchController.text),
              child: Text(
                'Search',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        if (categoryProvider.categories.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categoryProvider.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];

              return CategoryChips(
                category: category,
                isSelected: categoryProvider.isSelected(category),
                onTap: () {
                  if (categoryProvider.isSelected(category)) {
                    categoryProvider.clearSelection();
                    return;
                  }
                  categoryProvider.selectCategory(category);

                  context.read<NavigationProvider>().setScreenIndex(1);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTitleSection(String title, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        TextButton(
          onPressed: () => onNavigation(index),
          child: Text(
            AppConstants.seeAll,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCardList() {
    return SizedBox(
      height: 300,
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isHomeLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            );
          }

          if (productProvider.tenProducts.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = productProvider.tenProducts;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length + 1, // +1 for See All
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              /// LAST CARD → SEE ALL
              if (index == products.length) {
                return SizedBox(
                  width: 100,
                  child: SeeAllCard(onTap: () => onNavigation(1)),
                );
              }

              /// NORMAL PRODUCT CARD
              final product = products[index];

              return ProductCard(
                product: product,
                onTap: () => onNavigation(1),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCartList() {
    return SizedBox(
      height: 160,
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isHomeLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            );
          }

          if (productProvider.tenProducts.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          final products = productProvider.tenProducts;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length + 1, // +1 for See All
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              /// LAST CARD → SEE ALL
              if (index == products.length) {
                return SizedBox(
                  width: 100,
                  child: SeeAllCard(onTap: () => onNavigation(2)),
                );
              }

              /// NORMAL PRODUCT CARD
              final product = products[index];

              return CartProductCard(
                product: product,
                onTap: () => onNavigation(2),
              );
            },
          );
        },
      ),
    );
  }
}
