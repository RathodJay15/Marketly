import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
// import 'package:marketly/data/migration/migrate_products.dart';
// import 'package:marketly/data/migration/migrate_category.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      context.read<ProductProvider>().fetchAllProducts();
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
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _onSearchPressed(value) async {
    FocusScope.of(context).unfocus();
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
      body: SafeArea(child: _buildBody()),
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(AppConstants.ourProducts),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProductList(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(AppConstants.cartProducts),
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            controller: _textSearchController,
            focusNode: _searchFocusNode,
            onTap: _startSearch,
            onSubmitted: (value) => _onSearchPressed(value),

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
                    onPressed: () =>
                        _onSearchPressed(_textSearchController.text),
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
          ),
        ),
        Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.filter_alt_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    );
  }

  Widget _buildProductList() {
    return SizedBox(
      height: 300,
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (productProvider.products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: productProvider.products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = productProvider.products[index];

              return Container(
                width: 190,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    InkWell(
                      splashColor: Theme.of(
                        context,
                      ).colorScheme.onInverseSurface.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        ////navigation
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// IMAGE
                            Expanded(
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(90),
                                          bottomRight: Radius.circular(90),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withValues(alpha: .30),
                                      ),
                                    ),
                                    CachedNetworkImage(
                                      imageUrl: product.thumbnail,
                                      height: 120,
                                      fit: BoxFit.contain,
                                      placeholder: (_, __) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// TITLE
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                              ),
                            ),

                            /// CATEGORY
                            Text(
                              product.category,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),

                            /// PRICE
                            Text(
                              '\$ ${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
