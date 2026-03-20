import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/core/constants/app_helpers.dart';
import 'package:marketly/presentation/user/orders/order_details_screen.dart';
import 'package:marketly/presentation/widgets/emptyState_screen.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<StatefulWidget> createState() => _myOrdersScreenState();
}

class _myOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user?.uid;

      if (userId != null) {
        context.read<OrderProvider>().fetchOrders(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _titleSection(),
            Expanded(child: _orderListScetion(context)),
          ],
        ),
      ),
    );
  }

  Widget _titleSection() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Iconoir(IconoirIcons.navArrowLeft),
            color: Theme.of(context).colorScheme.onInverseSurface,
            iconSize: 35,
          ),
          Text(
            AppConstants.myOrders,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onInverseSurface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
  // ---------------------------------------------------------------------------
  // Product List Section
  // ---------------------------------------------------------------------------

  Widget _orderListScetion(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        if (orderProvider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          );
        }
        if (orderProvider.orders.isEmpty) {
          return Center(
            child: EmptystateScreen.emptyState(
              icon: IconoirIcons.deliveryTruck,
              title: AppConstants.emptyOrdersTitle,
              subtitle: AppConstants.emptyOrdersSubtitle,
              context: context,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderProvider.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OrderDetailsScreen(orderId: order.id),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _orderItemThumbnails(order.items),

                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order No. : ${order.orderNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onInverseSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Placed on : ${AppHelpers.formatedDate(order.statusTimeline[0]['time'])}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Row(
                              children: [
                                Text(
                                  "Items : ${order.items.length}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Totel : ${order.pricing['total'].toStringAsFixed(2)} ₹",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Iconoir(
                        IconoirIcons.navArrowRight,
                        size: 25,
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _orderItemThumbnails(List<Map<String, dynamic>> items) {
    final displayItems = items.take(4).toList();

    // Single item → full thumbnail
    if (displayItems.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          displayItems.first['image'],
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          if (index >= displayItems.length) {
            // Empty slot for 2 or 3 items
            return const SizedBox();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              displayItems[index]['image'],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
