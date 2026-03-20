import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/cart_screen.dart';
import 'package:marketly/presentation/user/home_screen_body.dart';
import 'package:marketly/presentation/user/menu/favorites_screen.dart';
import 'package:marketly/presentation/user/menu/menu_screen.dart';
import 'package:marketly/presentation/user/menu/my_account_screen.dart';
import 'package:marketly/presentation/user/menu/saved_addresses_screen.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
import 'package:marketly/presentation/user/search_products_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/user_provider.dart';
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

  void goToFavorites() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritesScreen()),
    );
  }

  void goToMyOrders() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyOrdersScreen()),
    );
  }

  void goToMyAccount() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyAccountScreen()),
    );
  }

  void goToMyAddresses() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SavedAddressesScreen()),
    );
  }

  void logout() async {
    final shouldExit = await MarketlyDialog.showMyDialog(
      context: context,
      title: AppConstants.logout,
      content: AppConstants.areYouSureLogout,
    );

    if (shouldExit == true) {
      context.read<NavigationProvider>().setScreenIndex(
        0,
      ); // set navbar to home
      context.read<CartProvider>().stopListening();
      context.read<UserProvider>().clearUser(); // App state
      await AuthService().logout(); // Firebase session
    }
  }

  void onNavigation(int index) {
    Provider.of<NavigationProvider>(
      context,
      listen: false,
    ).setScreenIndex(index);

    Navigator.pop(context);
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
        resizeToAvoidBottomInset: false,
        drawer: _buildDrawer(),
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
              final cartItems = context.select<CartProvider, int>(
                (p) => p.items.length,
              );
              return Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  borderRadius: BorderRadius.circular(10),
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
                  selectedIconTheme: IconThemeData(size: 30),
                  unselectedIconTheme: IconThemeData(size: 25),
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedItemColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 0,
                  items: [
                    BottomNavigationBarItem(
                      icon: Iconoir(IconoirIcons.home),
                      label: AppConstants.home,
                    ),
                    BottomNavigationBarItem(
                      icon: Iconoir(IconoirIcons.search),
                      label: AppConstants.search,
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          Iconoir(IconoirIcons.cartAlt),
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
                      icon: Iconoir(IconoirIcons.menu),
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

  Widget _buildDrawer() {
    final user = context.watch<UserProvider>().user;
    if (user == null) {
      return const SizedBox();
    }
    final hasValidUrl = user.profilePic != null && user.profilePic!.isNotEmpty;
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(dividerColor: Theme.of(context).colorScheme.onPrimary),
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: GestureDetector(
                  onTap: () => goToMyAccount(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasValidUrl
                            ? Image.network(
                                user.profilePic!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 80,
                                  width: 80,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                  child: Center(
                                    child: const Iconoir(
                                      IconoirIcons.user,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                height: 80,
                                width: 80,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                child: Center(
                                  child: const Iconoir(
                                    IconoirIcons.user,
                                    size: 30,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        user.name.isEmpty ? AppConstants.username : user.name,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email.isEmpty ? AppConstants.username : user.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              Divider(color: Theme.of(context).colorScheme.onPrimary),

              _drawerListTile(
                icon: IconoirIcons.home,
                text: AppConstants.home,
                onTap: () => onNavigation(0),
              ),

              _drawerListTile(
                icon: IconoirIcons.search,
                text: AppConstants.search,
                onTap: () => onNavigation(1),
              ),

              _drawerListTile(
                icon: IconoirIcons.cartAlt,
                text: AppConstants.cart,
                onTap: () => onNavigation(2),
              ),

              _drawerListTile(
                icon: IconoirIcons.menu,
                text: AppConstants.menu,
                onTap: () => onNavigation(3),
              ),

              _drawerListTile(
                icon: IconoirIcons.user,
                text: AppConstants.myAccount,
                onTap: () => goToMyAccount(),
              ),

              _drawerListTile(
                icon: IconoirIcons.pinAlt,
                text: AppConstants.savedAdrs,
                onTap: () => goToMyAddresses(),
              ),

              _drawerListTile(
                icon: IconoirIcons.heart,
                text: AppConstants.favorites,
                onTap: () => goToFavorites(),
              ),

              _drawerListTile(
                icon: IconoirIcons.list,
                text: AppConstants.myOrders,
                onTap: () => goToMyOrders(),
              ),

              Divider(color: Theme.of(context).colorScheme.onPrimary),

              _drawerListTile(
                icon: IconoirIcons.logOut,
                text: AppConstants.logout,
                onTap: () => logout(),
                navButton: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerListTile({
    required IconoirIcons icon,
    required String text,
    required VoidCallback onTap,
    bool navButton = true,
  }) {
    return ListTile(
      leading: Iconoir(
        icon,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      title: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.onInverseSurface),
      ),
      onTap: () {
        onTap();
      },
      trailing: navButton
          ? Iconoir(
              IconoirIcons.navArrowRight,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 25,
            )
          : null,
    );
  }
}
