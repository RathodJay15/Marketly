import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/cart_item_model.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/data/services/product_service.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  State<ProductDetailsScreen> createState() => _roductDetailsScreenState();
}

class _roductDetailsScreenState extends State<ProductDetailsScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final ProductService _productService = ProductService();
  ProductModel? _product;
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await _productService.fetchProductById(widget.productId);

      if (!mounted) return;

      setState(() {
        _product = product;
        _rating = product.rating;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Product not found";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Text(
            _error!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
            ),
          ),
        ),
      );
    }

    final product = _product!;
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
              onPressed: () async {
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

                final confirm = await MarketlyDialog.showMyDialog(
                  context: context,
                  actionN: AppConstants.no,
                  actionY: AppConstants.yes,
                  title: AppConstants.addedToCart,
                  content: AppConstants.goToCart,
                  actionYColor: Theme.of(context).colorScheme.onSecondary,
                );
                if (confirm == true) {
                  Provider.of<NavigationProvider>(
                    context,
                    listen: false,
                  ).setScreenIndex(2);
                  Navigator.pop(context);
                }
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
      items: images.asMap().entries.map<Widget>((entry) {
        final int index = entry.key;
        final String img = entry.value;
        return GestureDetector(
          onTap: () => _openImagePreview(images, index),
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
                AppConstants.dolrAmount(product.price),
                style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              AppConstants.discountOff(product.discountPercentage),
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

        _sectionTitle(AppConstants.description),
        _sectionDetail(product.description),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(AppConstants.category),
                _sectionTitle(AppConstants.brand),
                _sectionTitle(AppConstants.stock),
                _sectionTitle(AppConstants.weight),
                _sectionTitle(AppConstants.tags),
                _sectionTitle(AppConstants.dimensions),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DraggableScrollableSheet(
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
                              AppConstants.dolrAmount(product.price),
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
                            AppConstants.discountOff(
                              product.discountPercentage,
                            ),
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

                      _sectionTitle(AppConstants.description),
                      _sectionDetail(product.description),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle(AppConstants.category),
                              _sectionTitle(AppConstants.brand),
                              _sectionTitle(AppConstants.stock),
                              _sectionTitle(AppConstants.weight),
                              _sectionTitle(AppConstants.tags),
                              _sectionTitle(AppConstants.dimensions),
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
      ),
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

  void _openImagePreview(List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          int currentIndex = initialIndex;
          final PageController controller = PageController(
            initialPage: initialIndex,
          );

          return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.primary,
                body: Stack(
                  children: [
                    /// SWIPE + PINCH ZOOM
                    PhotoViewGallery.builder(
                      pageController: controller,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() => currentIndex = index);
                      },
                      builder: (context, index) {
                        return PhotoViewGalleryPageOptions(
                          imageProvider: NetworkImage(images[index]),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                        );
                      },
                      backgroundDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),

                    /// CLOSE BUTTON
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            size: 28,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    /// IMAGE INDEX TEXT
                    Positioned(
                      bottom: 30,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "${currentIndex + 1} / ${images.length}",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 16,
                          ),
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
}
