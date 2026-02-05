import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/presentation/widgets/product_details.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  // final VoidCallback? onTap;

  const ProductCard({super.key, required this.product /*this.onTap*/});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      //decoration
      closedColor: Colors.transparent,
      openColor: Theme.of(context).scaffoldBackgroundColor,
      closedElevation: 0,
      openElevation: 0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      transitionDuration: const Duration(milliseconds: 200),
      openBuilder: (context, _) => ProductDetailsScreen(product: product),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: openContainer,
        child: Container(
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
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// IMAGE
                    Center(
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimary.withValues(alpha: .30),
                            ),
                          ), // for grey background
                          CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            height: 120,
                            width: 120,
                            fit: BoxFit.fill,
                            errorWidget: (_, __, ___) => Container(
                              color: Theme.of(context).colorScheme.onPrimary,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ],
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
                        color: Theme.of(context).colorScheme.onInverseSurface,
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

                    Spacer(),

                    /// PRICE
                    Text(
                      '\$ ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,

                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const CartProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 105,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /// IMAGE
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                              topRight: Radius.circular(45),
                              bottomLeft: Radius.circular(45),
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimary.withValues(alpha: .30),
                          ),
                        ),
                        CachedNetworkImage(
                          imageUrl: product.thumbnail,
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                          errorWidget: (_, __, ___) => Container(
                            color: Theme.of(context).colorScheme.onPrimary,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// TITLE
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),

                  Spacer(),

                  /// PRICE
                  Text(
                    '\$ ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,

                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SeeAllCard extends StatelessWidget {
  final VoidCallback onTap;

  const SeeAllCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Center(
          child: Text(
            'See All',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
