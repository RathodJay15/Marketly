import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});
  @override
  State<StatefulWidget> createState() => _orderDetailsScreen();
}

class _orderDetailsScreen extends State<OrderDetailsScreen> {
  OrderModel? _order;
  String? _error;

  @override
  void initState() {
    _loadOrder();
    super.initState();
  }

  Future<void> _loadOrder() async {
    try {
      final orderProvider = context.read<OrderProvider>();
      final order = await orderProvider.fetchOrderById(widget.orderId);

      if (!mounted) return;

      setState(() {
        _order = order;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = "Order not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            _titleSection(),
            if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 20,
                  ),
                ),
              )
            else if (_order == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              _orderDetails(_order!),
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
            icon: Icon(Icons.chevron_left_rounded),
            color: Theme.of(context).colorScheme.onInverseSurface,
            iconSize: 35,
          ),
          Text(
            AppConstants.orderDetails,
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

  Widget _orderDetails(OrderModel order) {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      children: [
        _sectionTitle(AppConstants.orderStatus),
        _greyCard(children: [_orderStatusTimeline(context, order)]),

        const SizedBox(height: 24),

        _sectionTitle(AppConstants.orderSummary),
        _greyCard(
          children: [
            _row(AppConstants.orderNo, order.orderNumber),
            Divider(color: Theme.of(context).colorScheme.onPrimary),

            ...order.items.map(
              (item) => _row(
                "${item['title']} x ${item['quantity']}",
                "\$${item['finalPrice'].toStringAsFixed(2)}",
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              AppConstants.subtotal,
              AppConstants.inrAmount(order.pricing['subtotal']),
            ),
            _row(
              AppConstants.discount,
              "-${AppConstants.inrAmount(order.pricing['discount'])}",
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              AppConstants.total,
              AppConstants.inrAmount(order.pricing['total']),
              isBold: true,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(AppConstants.paymentDetails),
        _greyCard(
          children: [_row("Method", order.paymentMethod, isBold: true)],
        ),
        const SizedBox(height: 24),

        _sectionTitle(AppConstants.usrDetails),
        _greyCard(
          children: [
            _row(AppConstants.username, order.userInfo['name']),
            _row(AppConstants.email, order.userInfo['email']),
            _row(AppConstants.phone, order.userInfo['phone']),
            _row(AppConstants.adrs, order.address['address']),
            _row(AppConstants.ct, order.address['city']),
            _row(AppConstants.state, order.address['state']),
            _row(AppConstants.cntry, order.address['country']),
            _row(AppConstants.pincode, order.address['pincode']),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _greyCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onInverseSurface,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderStatusTimeline(BuildContext context, OrderModel item) {
    const List<String> orderSteps = [
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
      children: List.generate(orderSteps.length, (index) {
        final status = orderSteps[index];
        final isCompleted = completedStatuses.containsKey(status);
        final isLast = index == orderSteps.length - 1;

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
    String formatStatus(String status) {
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
            formatStatus(status),
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
