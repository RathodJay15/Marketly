import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/admin/crud_product/add_product.dart';
import 'package:marketly/presentation/admin/crud_product/edit_product.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:marketly/providers/product_provider.dart';
import 'package:provider/provider.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<StatefulWidget> createState() => _allProductsState();
}

class _allProductsState extends State<AllProducts> {
  final TextEditingController _textSearchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchAllProducts();
    });
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
      context.read<ProductProvider>().fetchAllProducts();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textSearchController.dispose();
    _searchFocusNode.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Iconoir(IconoirIcons.navArrowLeft, size: 30),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () async {
            await context.read<AdminDashboardProvider>().refreshDashboard();
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.products,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<ProductProvider>(
          builder: (context, provider, _) {
            if (provider.isSearchLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Text(
                  provider.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            final products = provider.visibleProducts;

            return ListView.builder(
              itemCount: products.isEmpty ? 2 : products.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildSearchSection();
                }

                if (index == 1) {
                  if (products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          AppConstants.noProductsAvailable,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddProduct()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          AppConstants.addProduct,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final product = products[index - 2];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      product.thumbnail,
                      height: 50,
                      width: 50,
                    ),
                    title: Text(
                      product.title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          AppConstants.inrAmount(product.price),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        _searchFocusNode.unfocus();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProduct(product: product),
                          ),
                        );
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Iconoir(IconoirIcons.editPencil),
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return TextField(
      style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
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
          height: 40,
          width: 40,
          child: Center(
            child: Iconoir(
              IconoirIcons.search,
              size: 25,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSearching)
              IconButton(
                icon: Icon(Icons.close),
                color: Theme.of(context).colorScheme.onInverseSurface,
                onPressed: _closeOrClearSearch,
              ),
            TextButton(
              onPressed: () => _onSearchPressed(_textSearchController.text),
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
    );
  }
}
