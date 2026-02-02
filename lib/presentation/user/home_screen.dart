import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/product_model.dart';
// import 'package:marketly/data/migration/migrate_products.dart';
// import 'package:marketly/data/migration/migrate_category.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/cart_screen.dart';
import 'package:marketly/presentation/user/profile_screen.dart';
import 'package:marketly/presentation/user/search_products_screen.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';
// import 'package:material_icons/';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _homeScreenState();
}

class _homeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //  keeps state alive in IndexedStack

  final TextEditingController _textSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  int _currenetIndex = 0;

  @override
  void initState() {
    super.initState();
    // migrateCategories();
    // migrateProducts();
    Future.microtask(() {
      context.read<CategoryProvider>().loadCategories();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchHomeProducts(limit: 10);
    });
  }

  // Migration Code-----------------------------------------------------
  // void migrateCategories() async {
  //   await CategoryMigrationService().migrateCategoriesToFirebase();
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('Migration completed')));
  // }

  // void migrateProducts() async {
  //   await ProductMigrationService().migrateProducts();
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text('Migration completed')));
  // }
  //--------------------------------------------------------------------

  void onNavigation(index) {
    setState(() {
      _currenetIndex = index;
    });
  }

  Future<void> onLogout() async {
    await AuthService().logout(); // Ends Firebase session
    context.read<UserProvider>().clearUser(); // Clears App state
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
    // TODO: implement dispose
    super.dispose();
    _textSearchController.dispose();
    _searchFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keepAlive

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: IndexedStack(
          index: _currenetIndex,
          children: [
            _buildBody(),
            SearchProductsScreen(),
            CartScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _navBar(_currenetIndex),
    );
  }

  Widget _buildBody() {
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
            child: CategoryChips(),
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
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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

  Widget _navBar(currentIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Container(
        height: 65,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onInverseSurface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 40,
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) {
                onNavigation(index);
              },
              backgroundColor: Colors.transparent,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.home, size: 20),
                  ),
                  label: AppConstants.home,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.search, size: 20),
                  ),
                  label: AppConstants.search,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.shopping_cart_outlined, size: 20),
                  ),
                  label: AppConstants.cart,
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 2, bottom: 2),
                    child: Icon(Icons.person, size: 20),
                  ),
                  label: AppConstants.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
