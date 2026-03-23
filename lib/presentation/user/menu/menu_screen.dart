import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/menu/favorites_screen.dart';
import 'package:marketly/presentation/user/menu/address/saved_addresses_screen.dart';
import 'package:marketly/presentation/user/notification_screen.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:marketly/presentation/user/menu/my_account_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<StatefulWidget> createState() => _menuScreenState();
}

class _menuScreenState extends State<MenuScreen> {
  void goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationScreen()),
    );
  }

  void goToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FavoritesScreen()),
    );
  }

  void goToMyOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyOrdersScreen()),
    );
  }

  void goToMyAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyAccountScreen()),
    );
  }

  void goToCart() {
    Provider.of<NavigationProvider>(context, listen: false).setScreenIndex(2);
  }

  void goToMyAddresses() {
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) {
      return const SizedBox();
    }
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        SizedBox(height: 20),

        _buildProfileCard(),

        SizedBox(height: 20),

        _buildTile(goToMyAccount, IconoirIcons.user, AppConstants.myAccount),

        SizedBox(height: 10),

        _buildTile(
          goToMyAddresses,
          IconoirIcons.pinAlt,
          AppConstants.savedAdrses,
        ),

        SizedBox(height: 10),

        _buildTile(
          goToNotifications,
          IconoirIcons.bell,
          AppConstants.notifications,
        ),

        SizedBox(height: 10),

        _buildTile(goToFavorites, IconoirIcons.heart, AppConstants.favorites),

        SizedBox(height: 10),

        _buildTile(goToMyOrders, IconoirIcons.list, AppConstants.myOrders),

        SizedBox(height: 10),

        _buildTile(goToCart, IconoirIcons.cartAlt, AppConstants.myCart),

        SizedBox(height: 10),

        _themeTile(
          currentTheme: user.themeMode, // 'system' | 'light' | 'dark'
          onChanged: (theme) async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'themeMode': theme});

            context.read<UserProvider>().setUser(
              user.copyWith(themeMode: theme),
            );
          },
        ),

        SizedBox(height: 10),

        _logoutTile(logout, IconoirIcons.logOut, AppConstants.logout),
        SizedBox(height: 95),
      ],
    );
  }

  Widget _buildTile(VoidCallback onTap, IconoirIcons icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Iconoir(
                icon,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 25,
              ),
              SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 18,
                ),
              ),
              Spacer(),
              Iconoir(
                IconoirIcons.navArrowRight,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoutTile(VoidCallback onTap, IconoirIcons icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Iconoir(
                icon,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 25,
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = context.watch<UserProvider>().user;
    final hasValidUrl =
        user?.profilePic != null && user!.profilePic!.isNotEmpty;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MyAccountScreen()),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(60)),
            clipBehavior: Clip.antiAlias,
            child: hasValidUrl
                ? Image.network(
                    user.profilePic!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: 120,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      child: Center(
                        child: const Iconoir(IconoirIcons.user, size: 30),
                      ),
                    ),
                  )
                : Container(
                    height: 120,
                    width: 120,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    child: Center(
                      child: const Iconoir(IconoirIcons.user, size: 60),
                    ),
                  ),
          ),
          SizedBox(height: 10),
          Text(
            user!.name.isEmpty ? AppConstants.username : user.name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user.email.isEmpty ? AppConstants.username : user.email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _themeTile({
    required String currentTheme, // 'system' | 'light' | 'dark'
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Iconoir(
              IconoirIcons.sunLight,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 25,
            ),

            const SizedBox(width: 10),

            Text(
              AppConstants.theme,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontSize: 18,
              ),
            ),

            const Spacer(),

            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentTheme,
                dropdownColor: Theme.of(
                  context,
                ).colorScheme.onSecondaryContainer,
                icon: Iconoir(
                  IconoirIcons.navArrowDown,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                items: [
                  DropdownMenuItem(
                    value: AppConstants.systemDdValue,
                    child: Text(
                      AppConstants.system,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.lightDdValue,
                    child: Text(
                      AppConstants.light,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.darkDdValue,
                    child: Text(
                      AppConstants.dark,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  onChanged(value);
                },
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
