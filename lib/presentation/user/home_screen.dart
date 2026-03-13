import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/user/cart_screen.dart';
import 'package:marketly/presentation/user/home_screen_body.dart';
import 'package:marketly/presentation/user/menu/menu_screen.dart';
import 'package:marketly/presentation/user/search_products_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _homeScreenState();
}

class _homeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; //  keeps state alive in IndexedStack

  @override
  void initState() {
    super.initState();
    // context.read<CartProvider>().startListening();
  }
  // migrateProducts();
  // migrateCategories();

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
    Provider.of<NavigationProvider>(
      context,
      listen: false,
    ).setScreenIndex(index);
  }

  Future<void> _confirmLeave() async {
    final shouldExit = await MarketlyDialog.showMyDialog(
      context: context,
      title: AppConstants.exit,
      content: AppConstants.areYouSureLeave,
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required for keepAlive

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmLeave();
      },
      child: Scaffold(
        extendBody: true,
        // resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: BottomBar(
          barColor: Colors.transparent,
          width: MediaQuery.of(context).size.width - 40,
          // fit: StackFit.expand,
          body: (context, controller) {
            return SafeArea(
              child: IndexedStack(
                index: context.select<NavigationProvider, int>(
                  (p) => p.screenIndex,
                ),
                children: const [
                  HomeScreenBody(),
                  SearchProductsScreen(),
                  CartScreen(),
                  MenuScreen(),
                ],
              ),
            );
          },

          child: Consumer<NavigationProvider>(
            builder: (context, navProvider, child) {
              final cartItems = context.watch<CartProvider>().items.length;
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: navProvider.screenIndex,
                  onTap: (index) {
                    navProvider.setScreenIndex(index);
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, size: 25),
                      label: AppConstants.home,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search, size: 25),
                      label: AppConstants.search,
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 25),
                          if (cartItems > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 12,
                                  minHeight: 12,
                                ),
                                child: Text(
                                  '$cartItems',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onInverseSurface,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: AppConstants.cart,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.menu_rounded, size: 25),
                      label: AppConstants.menu,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
