import 'package:flutter/material.dart';
import 'package:marketly/data/models/order_model.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel order;

  OrderDetailsScreen({required this.order});
  @override
  State<StatefulWidget> createState() => _orderDetailsScreen();
}

class _orderDetailsScreen extends State<OrderDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final OrderModel order = widget.order;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [_titleSection(), _orderDetails(order)],
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
            'Order details',
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
        _sectionTitle("User Details"),
        _greyCard(
          children: [
            _row("Name", order.userInfo['name']),
            _row("Email", order.userInfo['email']),
            _row("Phone", order.userInfo['phone']),
            _row("Address", order.address['address']),
            _row("City", order.address['city']),
            _row("State", order.address['state']),
            _row("Country", order.address['country']),
            _row("Pincode", order.address['pincode']),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle("Order Summary"),
        _greyCard(
          children: [
            ...order.items.map(
              (item) => _row(
                "${item['title']} x ${item['quantity']}",
                "\$${item['finalPrice'].toStringAsFixed(2)}",
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              "Subtotal",
              "\$${order.pricing['subtotal'].toStringAsFixed(2)}",
            ),
            _row(
              "Discount",
              "-\$${order.pricing['discount'].toStringAsFixed(2)}",
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              "Total",
              "\$${order.pricing['total'].toStringAsFixed(2)}",
              isBold: true,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle("Payment Details"),
        _greyCard(
          children: [_row("Method", "${order.paymentMethod}", isBold: true)],
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
}
