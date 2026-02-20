import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
// import 'package:marketly/data/migration/migrate_products.dart';
// import 'package:marketly/data/migration/migrate_category.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/cart_screen.dart';
import 'package:marketly/presentation/user/home_screen_body.dart';
import 'package:marketly/presentation/user/menu/menu_screen.dart';
import 'package:marketly/presentation/user/search_products_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
    context.read<CartProvider>().startListening();

    // migrateCategories();
    // migrateProducts();
  }
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

  Future<void> onLogout() async {
    await AuthService().logout(); // Ends Firebase session
    context.read<UserProvider>().clearUser(); // Clears App state
    context.read<CartProvider>().stopListening();
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: IndexedStack(
            index: context.select<NavigationProvider, int>(
              (p) => p.screenIndex,
            ),
            children: [
              HomeScreenBody(),
              SearchProductsScreen(),
              CartScreen(),
              MenuScreen(),
            ],
          ),
        ),
        bottomNavigationBar: _navBar(),
      ),
    );
  }

  Widget _navBar() {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        final currentIndex = navProvider.screenIndex;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Container(
            height: 65,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(35),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 40,
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    onNavigation(index);
                  },
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900),
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: Icon(Icons.home, size: 20),
                      ),
                      label: AppConstants.home,
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: Icon(Icons.search, size: 20),
                      ),
                      label: AppConstants.search,
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: Icon(Icons.shopping_cart_outlined, size: 20),
                      ),
                      label: AppConstants.cart,
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: EdgeInsets.only(top: 2, bottom: 2),
                        child: Icon(Icons.menu_rounded, size: 20),
                      ),
                      label: AppConstants.menu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
