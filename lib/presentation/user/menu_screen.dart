import 'package:flutter/material.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
      MaterialPageRoute(builder: (_) => MyOrdersScreen()),
    );
  }

  void goToCart() {
    Provider.of<NavigationProvider>(context, listen: false).setScreenIndex(2);
  }

  void goToMyAddresses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyOrdersScreen()),
    );
  }

  void logout() async {
    await AuthService().logout(); // Firebase session
    context.read<UserProvider>().clearUser(); // App state
    context.read<CartProvider>().stopListening();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTile(goToMyAccount, Icons.person, 'My Account'),
        _buildTile(goToMyAddresses, Icons.location_on, 'Saved Addresses'),
        _buildTile(
          goToMyOrders,
          Icons.format_list_bulleted_rounded,
          'My Order',
        ),
        _buildTile(goToCart, Icons.shopping_cart, 'My Cart'),
        _buildTile(logout, Icons.logout_outlined, 'Logout'),
      ],
    );
  }

  Widget _buildTile(VoidCallback onTap, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10),
          height: 60,
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
                size: 35,
              ),
              SizedBox(width: 20),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 20,
                ),
              ),
              Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
