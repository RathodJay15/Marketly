import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/category_model.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/presentation/user/menu/my_account_screen.dart';
import 'package:marketly/presentation/user/notification_screen.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/providers/notification_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          floating: true,
          snap: true,
          toolbarHeight: 70,
          titleSpacing: 20,
          title: _buildProfileCard(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildSearchSection(),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCategoryChips(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(AppConstants.ourProducts, 1, true),
          ),
        ),
        // const SizedBox(height: 12),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildProductCardList(),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTitleSection(
              AppConstants.cartProducts,
              2,
              context.watch<CartProvider>().items.isNotEmpty,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: _buildCartList(),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 95)),
      ],
    );
  }

  Widget _buildProfileCard() {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final isLoading = userProvider.isLoading;

    final notificationProvider = context.watch<NotificationProvider>();
    final hasUnread = notificationProvider.unreadCount > 0;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyAccountScreen()),
      ),
      child: Skeletonizer(
        enabled: isLoading,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              child: IconButton(
                icon: Iconoir(IconoirIcons.menu),
                iconSize: 28,
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),

            SizedBox(width: 13),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  user?.name.isNotEmpty == true
                      ? user!.name
                      : AppConstants.username,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            Stack(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: IconButton(
                    icon: Iconoir(IconoirIcons.bell),
                    iconSize: 28,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationScreen()),
                      );
                    },
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                ),

                //  Red Dot Indicator
                if (hasUnread)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  user?.profilePic != null &&
                      user!.profilePic!.isNotEmpty &&
                      !isLoading
                  ? CachedNetworkImage(
                      imageUrl: user.profilePic!,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 50,
                        width: 50,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 50,
                        width: 50,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        child: const Iconoir(IconoirIcons.user, size: 30),
                      ),
                    )
                  : Container(
                      height: 50,
                      width: 50,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      child: Center(
                        child: Iconoir(
                          IconoirIcons.user,
                          size: 30,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
            ),
          ],
        ),
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
          prefixIcon: SizedBox(
            height: 30,
            width: 30,
            child: Center(
              child: Iconoir(
                IconoirIcons.search,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 30,
              ),
            ),
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
    // final products = productProvider.tenProducts;
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final isLoading = categoryProvider.isLoading;

        // Use fake list when loading
        final categories = isLoading
            ? List.generate(5, (_) => CategoryModel.skeleton())
            : categoryProvider.categories;

        if (!isLoading && categories.isEmpty) {
          return const SizedBox();
        }

        return SizedBox(
          height: 40,
          child: Skeletonizer(
            enabled: isLoading,
            enableSwitchAnimation: true,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];

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
          ),
        );
      },
    );
  }

  Widget _buildTitleSection(String title, int index, bool isNotEmpty) {
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
        if (isNotEmpty)
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
          final isLoading = productProvider.isHomeLoading;

          // Use fake list when loading
          final products = isLoading
              ? List.generate(5, (_) => ProductModel.skeleton())
              : productProvider.tenProducts;

          if (!isLoading && products.isEmpty) {
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
          // final products = productProvider.tenProducts;

          return Skeletonizer(
            enabled: isLoading,
            enableSwitchAnimation: true,
            child: ListView.separated(
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
            ),
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
