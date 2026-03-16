import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/notification_model.dart';
import 'package:marketly/presentation/user/orders/order_details_screen.dart';
import 'package:marketly/presentation/widgets/emptyState_screen.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:marketly/providers/notification_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<StatefulWidget> createState() => _notificationScreenState();
}

class _notificationScreenState extends State<NotificationScreen> {
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
            AppConstants.notifications,
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

  Widget _orderListScetion(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final notifications = notificationProvider.notifications;
        if (notificationProvider.notifications.isEmpty) {
          return Center(
            child: EmptystateScreen.emptyState(
              icon: IconoirIcons.bell,
              title: AppConstants.emptyNotificationsTitle,
              subtitle: AppConstants.emptyNotificationsSubtitle,
              context: context,
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationTile(
                context,
                notification,
                notificationProvider,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    AppNotification notification,
    NotificationProvider provider,
  ) {
    final orderProvider = context.read<OrderProvider>();

    return GestureDetector(
      onTap: () async {
        if (!notification.isRead) {
          await provider.markAsRead(notification.id);
        }
        if (notification.title == 'Order Update') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(orderId: notification.orderId),
            ),
          );
        } else if (notification.title == 'Cart Expiring Soon') {
          context.read<NavigationProvider>().setScreenIndex(2);
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.title == 'Order Update')
              FutureBuilder(
                future: orderProvider.fetchOrderById(notification.orderId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      width: 72,
                      height: 72,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    );
                  }

                  final order = snapshot.data!;
                  return _orderItemThumbnails(order.items);
                },
              ),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
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
