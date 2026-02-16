import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/services/auth_service.dart';
import 'package:marketly/presentation/admin/crud_category/all_categories.dart';
import 'package:marketly/presentation/admin/crud_product/all_products.dart';
import 'package:marketly/presentation/admin/users/all_users.dart';
import 'package:marketly/presentation/admin/orders/all_orders.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().fetchDashboardStats();
    });
  }

  void onLogout() async {
    final shouldExit = await MarketlyDialog.showMyDialog(
      context: context,
      title: AppConstants.logout,
      content: AppConstants.areYouSureLogout,
    );

    if (shouldExit == true) {
      await AuthService().logout(); // Firebase session
      context.read<UserProvider>().clearUser(); // App state
    }
  }

  void _goToCategories() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AllCategories()));
  }

  void _goToProducts() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AllProducts()));
  }

  void _goToUsers() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AllUsers()));
  }

  void _goToOrders() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AllOrders()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        title: Text(
          AppConstants.adminDashBoard,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
            onPressed: onLogout,
          ),
        ],
      ),
      body: Consumer<AdminDashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            );
          }
          return ListView(
            shrinkWrap: true,
            children: [
              _stats(dashboardProvider),

              _sectionTitle(AppConstants.category),

              _subTitleTile(
                icon: Icons.category_rounded,
                title: '${AppConstants.totalCategories} : ',
                titleVal: dashboardProvider.totalCategories.toString(),
                subtitle1: '${AppConstants.active} : ',
                subtitle1Val: dashboardProvider.activeCategories.toString(),
                subtitle2: '${AppConstants.inActive} : ',
                subtitle2Val: dashboardProvider.inactiveCategories.toString(),
                onTap: () => _goToCategories(),
              ),
              _sectionTitle(AppConstants.products),

              _titleTile(
                icon: Icons.card_giftcard_rounded,
                label: AppConstants.totalProducts,
                value: dashboardProvider.totalProducts.toString(),
                onTap: () => _goToProducts(),
              ),

              _sectionTitle(AppConstants.orders),

              _subTitleTile(
                icon: Icons.local_shipping_rounded,
                title: '${AppConstants.totalOrders} : ',
                titleVal: dashboardProvider.totalOrders.toString(),
                subtitle1: '${AppConstants.confirmed} : ',
                subtitle1Val: dashboardProvider.confirmedOrders.toString(),
                subtitle2: '${AppConstants.pending} : ',
                subtitle2Val: dashboardProvider.pendingOrders.toString(),
                onTap: () => _goToOrders(),
              ),

              _sectionTitle(AppConstants.users),

              _titleTile(
                icon: Icons.person,
                label: AppConstants.totalUsers,
                value: dashboardProvider.totalUsers.toString(),
                onTap: () => _goToUsers(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stats(AdminDashboardProvider dashboardProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 213,
        width: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statbox(
                  icon: Icons.person,
                  label: AppConstants.users,
                  value: dashboardProvider.totalUsers.toString(),
                  width: 190,
                ),
                _statbox(
                  icon: Icons.local_shipping_rounded,
                  label: AppConstants.orders,
                  value: dashboardProvider.totalOrders.toString(),
                  width: 190,
                ),
              ],
            ),
            _statbox(
              icon: Icons.attach_money_rounded,
              label: AppConstants.revenue,
              value: AppConstants.dolrAmount(dashboardProvider.totalRevenue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statbox({
    required IconData icon,
    required String label,
    required String value,
    double? width,
  }) {
    return Container(
      height: 100,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onInverseSurface,
                size: 40,
              ),
              SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 25,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _titleTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onTap(),
                icon: Icon(Icons.chevron_right_rounded, size: 30),
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subTitleTile({
    required IconData icon,
    required String title,
    required String titleVal,
    required String subtitle1,
    required String subtitle1Val,
    required String subtitle2,
    required String subtitle2Val,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                          ),
                        ),
                        Text(
                          titleVal,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          subtitle1,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                          ),
                        ),
                        Text(
                          subtitle1Val,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(
                          subtitle2,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                          ),
                        ),
                        Text(
                          subtitle2Val,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => onTap(),
                icon: Icon(Icons.chevron_right_rounded, size: 30),
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
