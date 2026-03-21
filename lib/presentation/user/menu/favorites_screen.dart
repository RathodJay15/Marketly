import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/presentation/widgets/emptyState_screen.dart';
import 'package:marketly/presentation/widgets/product_details.dart';
import 'package:marketly/providers/favorites_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void didChangeDependencies() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).clearSnackBars();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _titleSection(context),
            Expanded(child: _favoritesListSection()),
          ],
        ),
      ),
    );
  }

  Widget _titleSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Iconoir(IconoirIcons.navArrowLeft),
            color: Theme.of(context).colorScheme.onInverseSurface,
            iconSize: 35,
          ),
          Text(
            AppConstants.favorites,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoritesListSection() {
    return Consumer2<FavoritesProvider, ProductProvider>(
      builder: (context, favoritesProvider, productProvider, _) {
        final likedIds = favoritesProvider.likedProductIds;
        final allProducts = productProvider.allProducts;

        // Filter only liked products
        final favoriteProducts = allProducts
            .where((product) => likedIds.contains(product.id))
            .toList();

        if (favoriteProducts.isEmpty) {
          return Center(
            child: EmptystateScreen.emptyState(
              icon: IconoirIcons.heart,
              title: AppConstants.emptyFavoritesTitle,
              subtitle: AppConstants.emptyFavoritesSubtitle,
              context: context,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: favoriteProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          clipBehavior: Clip.antiAlias,
          itemBuilder: (context, index) {
            final product = favoriteProducts[index];
            return _favoriteTile(context, product);
          },
        );
      },
    );
  }

  Widget _favoriteTile(BuildContext context, ProductModel product) {
    return OpenContainer(
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      openBuilder: (context, _) {
        FocusManager.instance.primaryFocus?.unfocus();
        return ProductDetailsScreen(productId: product.id, fromFavorites: true);
      },
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
          padding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              /// Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.thumbnail,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Theme.of(context).colorScheme.onPrimary,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppConstants.inrAmount(product.price),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<FavoritesProvider>(
                builder: (context, provider, _) {
                  final isLiked = provider.isLiked(product.id);

                  return IconButton(
                    icon: Icon(
                      isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    color: isLiked
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      final userId = context.read<UserProvider>().user?.uid;

                      if (userId == null) return;

                      provider.toggleLike(userId, product.id);
                    },
                    iconSize: 28,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
