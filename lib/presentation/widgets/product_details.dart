import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:marketly/data/models/cart_item_model.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _roductDetailsScreenState();
}

class _roductDetailsScreenState extends State<ProductDetailsScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  int _currentIndex = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final product = widget.product;
    final images = product.images;
    _rating = product.rating;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: isLandscape
            ? _landscapeLayout(product, images)
            : _portraitLayout(product, images),
      ),
    );
  }

  // ----------------------------------------------------
  // PORTRAIT LAYOUT
  // ----------------------------------------------------

  Widget _portraitLayout(ProductModel product, List images) {
    return Stack(
      children: [
        Column(
          children: [
            _topBar(product),
            const SizedBox(height: 16),
            _carousel(images, height: 350),
            const SizedBox(height: 12),
            _thumbnails(images),
          ],
        ),
        _bottomSheet(product),
      ],
    );
  }

  // ----------------------------------------------------
  // LANDSCAPE LAYOUT
  // ----------------------------------------------------

  Widget _landscapeLayout(ProductModel product, List images) {
    return Row(
      children: [
        /// LEFT — CAROUSEL
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _topBar(product),
              Expanded(child: _carousel(images)),
              const SizedBox(height: 12),
              _thumbnails(images),
              const SizedBox(height: 5),
            ],
          ),
        ),

        /// RIGHT — DETAILS
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: Border.all(
                width: 1,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: _detailsContent(product),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // TOP BAR
  // ----------------------------------------------------

  Widget _topBar(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: Icon(
                Icons.add_shopping_cart_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              onPressed: () {
                final cartProvider = context.read<CartProvider>();

                final cartItem = CartItemModel(
                  id: '',
                  productId: product.id,
                  title: product.title,
                  price: product.price,
                  quantity: 1,
                  total: product.price,
                  discountedTotal:
                      product.price -
                      (product.price * product.discountPercentage / 100),
                  discountPercentage: product.discountPercentage,
                  thumbnail: product.thumbnail,
                );

                cartProvider.addToCart(cartItem);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Product added to cart',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onInverseSurface,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // ----------------------------------------------------
  // CAROUSEL
  // ----------------------------------------------------

  Widget _carousel(List images, {double? height}) {
    return CarouselSlider(
      carouselController: _carouselController,
      options: CarouselOptions(
        height: height,
        enlargeCenterPage: true,
        reverse: false,
        enableInfiniteScroll: true,
        viewportFraction: 0.85,
        onPageChanged: (index, _) {
          setState(() => _currentIndex = index);
        },
      ),
      items: images.map<Widget>((img) {
        return GestureDetector(
          onTap: () => _openImagePreview(img),
          child: Container(
            width: 350,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: CachedNetworkImage(
              imageUrl: img,
              height: 120,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ----------------------------------------------------
  // THUMBNAILS
  // ----------------------------------------------------

  Widget _thumbnails(List images) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(images.length, (index) {
        final isSelected = _currentIndex == index;
        return GestureDetector(
          onTap: () => _carouselController.animateToPage(index),
          child: Container(
            height: 50,
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onInverseSurface
                    : Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            child: CachedNetworkImage(
              imageUrl: images[index],
              height: 120,
              fit: BoxFit.contain,
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.onInverseSurface,
                child: Icon(Icons.image_not_supported),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ----------------------------------------------------
  // LANDSCAPE RIGHT SIDE DETAILS CONTENT
  // ----------------------------------------------------

  Widget _detailsContent(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// TITLE + PRICE
        Text(
          product.title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '\$${product.price}',
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${product.discountPercentage}% off',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        /// RATING
        Row(
          children: [
            RatingBarIndicator(
              rating: _rating,
              itemBuilder: (_, __) => Icon(
                Icons.star_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              itemCount: 5,
              itemSize: 28,
            ),
            const SizedBox(width: 10),
            Text(
              _rating.toStringAsFixed(1),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _sectionTitle("Description"),
        _sectionDetail(product.description),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle("Category"),
                _sectionTitle("Brand"),
                _sectionTitle("Stock"),
                _sectionTitle("Weight"),
                _sectionTitle("Tags"),
                _sectionTitle("Dimensions"),
              ],
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionDetail(product.category),
                _sectionDetail(product.brand),
                _sectionDetail(product.stock.toString()),
                _sectionDetail(product.weight.toString()),
                _sectionDetail(product.formattedTags()),
                SizedBox(
                  width: 260,
                  child: _sectionDetail(product.formattedDimensions()),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    ),
  );
  Widget _sectionDetail(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 18,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    ),
  );

  // ----------------------------------------------------
  // PORTRAIT BOTTOM SHEET
  // ----------------------------------------------------

  Widget _bottomSheet(ProductModel product) {
    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.38,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _dragHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    /// TITLE + PRICE
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(
                                context,
                              ).colorScheme.onInverseSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${product.discountPercentage}% off',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    /// RATING
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: _rating,
                          itemBuilder: (_, __) => Icon(
                            Icons.star_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          itemCount: 5,
                          itemSize: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _sectionTitle("Description"),
                    _sectionDetail(product.description),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Category"),
                            _sectionTitle("Brand"),
                            _sectionTitle("Stock"),
                            _sectionTitle("Weight"),
                            _sectionTitle("Tags"),
                            _sectionTitle("Dimensions"),
                          ],
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionDetail(product.category),
                            _sectionDetail(product.brand),
                            _sectionDetail(product.stock.toString()),
                            _sectionDetail(product.weight.toString()),
                            _sectionDetail(product.formattedTags()),
                            SizedBox(
                              width: 260,
                              child: _sectionDetail(
                                product.formattedDimensions(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dragHandle() => Center(
    child: Container(
      height: 5,
      width: 40,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
  // ----------------------------------------------------
  // IMAGE PREVIEW
  // ----------------------------------------------------

  void _openImagePreview(String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Theme.of(context).colorScheme.onPrimary,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primary,
            body: SafeArea(
              child: Stack(
                children: [
                  /// IMAGE WITH PINCH ZOOM
                  Center(
                    child: PinchZoom(
                      maxScale: 5,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.image_not_supported,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          size: 60,
                        ),
                      ),
                    ),
                  ),

                  /// CLOSE BUTTON
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
