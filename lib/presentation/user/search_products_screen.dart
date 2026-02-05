import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
import 'package:marketly/presentation/widgets/product_details.dart';
import 'package:marketly/providers/category_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
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

  String? _lastCategorySlug;
  bool _fetchScheduled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final categoryProvider = context.read<CategoryProvider>();
    final navProvider = context.read<NavigationProvider>();

    final slug = categoryProvider.selectedCategorySlug;

    // Handle search focus safely
    if (navProvider.requestSearchFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _isSearching = true;
        _searchFocusNode.requestFocus();
        navProvider.clearSearchFocusRequest();
      });
    }

    // Detect category change ONLY
    if (slug != _lastCategorySlug && !_fetchScheduled) {
      _lastCategorySlug = slug;
      _fetchScheduled = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final productProvider = context.read<ProductProvider>();

        if (slug != null) {
          productProvider.fetchProductsByCategory(slug);
        } else {
          productProvider.fetchAllProducts();
        }

        _fetchScheduled = false;
      });
    }
  }

  void _onFocusChange() {
    if (!_searchFocusNode.hasFocus && _textSearchController.text.isEmpty) {
      if (_isSearching) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _startSearch() {
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
    }
    Provider.of<CategoryProvider>(context, listen: false).clearSelection();
    _searchFocusNode.requestFocus();
  }

  void _onSearchPressed(value) async {
    _searchFocusNode.unfocus();
  }

  void _closeOrClearSearch() {
    if (_textSearchController.text.isNotEmpty) {
      _textSearchController.clear();
      _onSearchPressed('');
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
    _searchFocusNode.removeListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildSearchSection(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildCategoryChips(),
            ),
            const SizedBox(height: 20),

            Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
                final productProvider = context.read<ProductProvider>();
                final slug = categoryProvider.selectedCategorySlug;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (slug != null) {
                    productProvider.fetchProductsByCategory(slug);
                  } else {
                    productProvider.fetchAllProducts();
                  }
                });
                return _buildProductCardGride();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
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
            onChanged: (value) {
              if (!_isSearching) {
                setState(() {
                  _isSearching = true;
                });
              }
              context.read<ProductProvider>().searchProducts(value);
            },
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
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Text(
                        AppConstants.search,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Container(
        //   padding: EdgeInsets.all(8),
        //   margin: EdgeInsets.only(left: 10),
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).colorScheme.onInverseSurface,
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Icon(
        //     Icons.filter_alt_outlined,
        //     color: Theme.of(context).colorScheme.primary,
        //     size: 40,
        //   ),
        // ),
      ],
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
                  categoryProvider.selectCategory(category);

                  final slug = categoryProvider.selectedCategorySlug;

                  if (slug != null) {
                    context.read<ProductProvider>().fetchProductsByCategory(
                      slug,
                    );
                  } else {
                    context.read<ProductProvider>().fetchAllProducts();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCardGride() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        final products = productProvider.visibleProducts;

        if (products.isEmpty) {
          return Center(
            child: Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 215,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isLandscape
                ? (215 / 310)
                : (215 / 340), //width-height
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        );
      },
    );
  }
}
