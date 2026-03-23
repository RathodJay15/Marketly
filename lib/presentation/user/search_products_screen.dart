import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/models/product_model.dart';
import 'package:marketly/presentation/widgets/category_chip.dart';
import 'package:marketly/presentation/widgets/emptyState_screen.dart';
import 'package:marketly/presentation/widgets/product_card.dart';
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

  late CategoryProvider _categoryProvider;
  String? _lastCategorySlug;

  late NavigationProvider _navigationProvider;

  bool _isSearching = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
      _navigationProvider.addListener(_handleNavigationChange);
      _categoryProvider.addListener(_handleCategoryChange);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _categoryProvider = context.read<CategoryProvider>();
    _navigationProvider = context.read<NavigationProvider>();
  }

  void _handleCategoryChange() {
    final slug = _categoryProvider.selectedCategorySlug;

    if (slug != _lastCategorySlug) {
      _lastCategorySlug = slug;

      //  Clear search text
      _textSearchController.clear();
      _searchFocusNode.unfocus();
      _isSearching = false;

      final productProvider = context.read<ProductProvider>();

      if (slug != null) {
        productProvider.fetchProductsByCategory(slug);
      } else {
        productProvider.fetchAllProducts();
      }
    }
  }

  void _handleNavigationChange() {
    final navProvider = context.read<NavigationProvider>();

    if (navProvider.requestSearchFocus && navProvider.screenIndex == 1) {
      _isSearching = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _searchFocusNode.requestFocus();
        navProvider.clearSearchFocusRequest();
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
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
    }
    context.read<ProductProvider>().searchProducts(value);
    _searchFocusNode.unfocus();
  }

  void _closeOrClearSearch() {
    if (_searchFocusNode.hasFocus) {
      // First press → just hide keyboard
      _searchFocusNode.unfocus();
    } else {
      // Second press → clear search completely
      _textSearchController.clear();

      context.read<ProductProvider>().clearSearchResult();
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
    _textSearchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _navigationProvider.removeListener(_handleNavigationChange);
    _categoryProvider.removeListener(_handleCategoryChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          onRefresh: () async {
            _closeOrClearSearch();
            _categoryProvider.clearSelection();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                floating: true,
                snap: true,
                toolbarHeight: 80,
                titleSpacing: 20,
                title: _buildSearchSection(),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildCategoryChips(),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 20)),

              _buildProductSliverGrid(),

              SliverToBoxAdapter(child: const SizedBox(height: 95)),
            ],
          ),
        ),
        Positioned(
          right: 20,
          bottom: 85,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
            foregroundColor: Theme.of(context).colorScheme.primary,
            splashColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: scrollToTop,
            child: Iconoir(IconoirIcons.longArrowLeftUp, size: 30),
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
            textInputAction: TextInputAction.done,
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
                  if (_isSearching)
                    IconButton(
                      icon: Iconoir(IconoirIcons.cancel, size: 30),
                      color: Theme.of(context).colorScheme.onInverseSurface,
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

  Widget _buildProductSliverGrid() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Selector<ProductProvider, List<ProductModel>>(
      selector: (_, provider) => provider.visibleProducts,
      builder: (context, products, _) {
        if (products.isEmpty) {
          return SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 100),
                Center(
                  child: EmptystateScreen.emptyState(
                    icon: IconoirIcons.boxIso,
                    title: AppConstants.emptyProductsTitle,
                    subtitle: AppConstants.emptyProductsSubtitle,
                    context: context,
                  ),
                ),
              ],
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return RepaintBoundary(
                child: ProductCard(product: products[index]),
              );
            }, childCount: products.length),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 215,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isLandscape ? (215 / 310) : (215 / 340),
            ),
          ),
        );
      },
    );
  }
}
