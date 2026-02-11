import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/menu/saved_addresses_screen.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
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
    await AuthService().logout(); // Firebase session
    context.read<UserProvider>().clearUser(); // App state
    context.read<NavigationProvider>().setScreenIndex(0); // set navbar to home
    context.read<CartProvider>().stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user!;
    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        _buildTile(goToMyAccount, Icons.person, AppConstants.myAccount),
        _buildTile(goToMyAddresses, Icons.location_on, AppConstants.savedAdrs),
        _buildTile(
          goToMyOrders,
          Icons.format_list_bulleted_rounded,
          AppConstants.myOrders,
        ),
        _buildTile(goToCart, Icons.shopping_cart, AppConstants.myCart),

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

        _buildTile(logout, Icons.logout_outlined, AppConstants.logout),
      ],
    );
  }

  Widget _buildTile(VoidCallback onTap, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10),
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
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
              Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeTile({
    required String currentTheme, // 'system' | 'light' | 'dark'
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.brightness_6_outlined,
              color: Theme.of(context).colorScheme.onInverseSurface,
              size: 25,
            ),

            const SizedBox(width: 10),

            Text(
              'Theme',
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
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                items: const [
                  DropdownMenuItem(value: 'system', child: Text('System')),
                  DropdownMenuItem(value: 'light', child: Text('Light')),
                  DropdownMenuItem(value: 'dark', child: Text('Dark')),
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
