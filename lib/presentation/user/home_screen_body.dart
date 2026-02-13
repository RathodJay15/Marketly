import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/user/menu/my_account_screen.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/providers/cart_provider.dart';
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

  @override
  void dispose() {
    super.dispose();
    _textSearchController.dispose();
    _searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: _buildProfileCard()),
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
    );
  }

  Widget _buildProfileCard() {
    final user = context.watch<UserProvider>().user;

    final hasValidUrl =
        user?.profilePic != null &&
        user!.profilePic!.isNotEmpty &&
        user.profilePic!.startsWith('http');
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyAccountScreen()),
      ),
      child: Row(
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
                user!.name.isEmpty ? AppConstants.username : user.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            clipBehavior: Clip.antiAlias,
            child: hasValidUrl
                ? Image.network(
                    user.profilePic!,
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 50,
                      width: 50,
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: const Icon(Icons.person, size: 24),
                    ),
                  )
                : Container(
                    height: 50,
                    width: 50,
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(Icons.person, size: 30),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return GestureDetector(
      onTap: () => context.read<NavigationProvider>().goToSearch(focus: true),
      child: TextField(
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
        enabled: false,
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
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Text(
                  AppConstants.search,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),
              ),
            ],
          ),
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
            return Center(
              child: Text(
                AppConstants.noProductFound,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
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
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }

  Widget _buildCartList() {
    return SizedBox(
      height: 160,
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          final products = cartProvider.items;
          if (products.isEmpty) {
            return Center(
              child: Text(
                AppConstants.emptyCartMsg,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          }
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
