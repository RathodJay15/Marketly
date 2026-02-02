import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:provider/provider.dart';

class SearchProductsScreen extends StatefulWidget {
  final String? initialProductId;

  const SearchProductsScreen({super.key, this.initialProductId});
  @override
  State<StatefulWidget> createState() => _searchProductScreenState();
}

class _searchProductScreenState extends State<SearchProductsScreen> {
  final TextEditingController _textSearchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      final productProvider = context.read<ProductProvider>();

      final slug = categoryProvider.selectedCategorySlug;

      if (slug != null) {
        productProvider.fetchProductsByCategory(slug);
      } else {
        productProvider.fetchAllProducts();
      }
    });
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

  void scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textSearchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        // pull to refresh API
        // await context.read<HomeController>().fetchHomeData();
      },
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          final products = productProvider.products;

          return Stack(
            children: [
              ListView(
                controller: _scrollController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildSearchSection(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CategoryChips(),
                  ),
                  const SizedBox(height: 20),

                  _buildProductCardGride(products),
                ],
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onInverseSurface,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  splashColor: Theme.of(context).colorScheme.onPrimary,
                  onPressed: () {
                    scrollToTop();
                  },
                  child: Icon(Icons.move_up),
                ),
              ),
            ],
          );
        },
      ),
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

  Widget _buildProductCardGride(products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 215,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) =>
            //         ProductDetailScreen(product: products[index]),
            //   ),
            // );
          },
        );
      },
    );
  }
}
