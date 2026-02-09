import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/presentation/user/orders/order_details_screen.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyOrdersScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _myOrdersScreenState();
}

class _myOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<UserProvider>().user!.uid;

      context.read<OrderProvider>().fetchOrders(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: ListView(
          children: [_titleSection(), _orderListScetion(context)],
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
            icon: Icon(Icons.chevron_left_rounded),
            color: Theme.of(context).colorScheme.onInverseSurface,
            iconSize: 35,
          ),
          Text(
            'My Orders',
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
          return const SizedBox(child: Text('No Order History!'));
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: orderProvider.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = orderProvider.orders[index];
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  iconColor: Theme.of(context).colorScheme.onInverseSurface,
                  collapsedIconColor: Theme.of(context).colorScheme.onPrimary,
                  title: _collapsedHeader(context, item),
                  children: [
                    _orderStatusTimeline(context, item),
                    SizedBox(
                      width: 160,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(order: item),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.onInverseSurface,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'View Order details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _collapsedHeader(BuildContext context, OrderModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _orderItemThumbnails(item.items),

        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order No. : ${item.orderNumber}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Placed on : ${AppConstants.formatedDate(item.statusTimeline[0]['time'])}",
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
                    "Items : ${item.items.length}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "Totel : ${item.pricing['total'].toStringAsFixed(2)} \$",
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

  Widget _orderStatusTimeline(BuildContext context, OrderModel item) {
    const List<String> _orderSteps = [
      'ORDER_PLACED',
      'ORDER_CONFIRMED',
      'ORDER_SHIPPED',
      'OUT_FOR_DELIVERY',
      'ORDER_DELIVERED',
    ];
    final completedStatuses = {
      for (var e in item.statusTimeline) e['status']: e['time'] as Timestamp,
    };
    return Column(
      children: List.generate(_orderSteps.length, (index) {
        final status = _orderSteps[index];
        final isCompleted = completedStatuses.containsKey(status);
        final isLast = index == _orderSteps.length - 1;

        return _timelineRow(
          context: context,
          status: status,
          time: isCompleted ? completedStatuses[status] : null,
          isCompleted: isCompleted,
          showLine: !isLast,
        );
      }),
    );
  }

  Widget _timelineRow({
    required BuildContext context,
    required String status,
    required Timestamp? time,
    required bool isCompleted,
    required bool showLine,
  }) {
    final activeColor = Theme.of(context).colorScheme.onSecondary;
    final inactiveColor = Theme.of(context).colorScheme.onPrimary;
    final activeIcon = Icons.check_box_rounded;
    final inactiveIcon = Icons.check_box_outline_blank_rounded;
    String _formatStatus(String status) {
      return status
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            isCompleted ? activeIcon : inactiveIcon,
            size: 30,
            color: isCompleted ? activeColor : inactiveColor,
          ),
        ),

        const SizedBox(width: 12),

        // MIDDLE: Status text
        Expanded(
          child: Text(
            _formatStatus(status),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),

        Text(
          time != null ? AppConstants.formatedDate(time) : 'pending',
          style: TextStyle(
            fontSize: 13,
            color: isCompleted
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
