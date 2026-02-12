import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/order_model.dart';
import 'package:marketly/providers/admin/admin_dashboard_provider.dart';
import 'package:provider/provider.dart';

class EditOrder extends StatefulWidget {
  final OrderModel order;

  EditOrder({required this.order});
  @override
  State<StatefulWidget> createState() => _editOrderScreen();
}

class _editOrderScreen extends State<EditOrder> {
  late Set<String> _selectedStatuses;

  static const List<String> _orderSteps = [
    'ORDER_PLACED',
    'ORDER_CONFIRMED',
    'ORDER_SHIPPED',
    'OUT_FOR_DELIVERY',
    'ORDER_DELIVERED',
  ];
  @override
  void initState() {
    super.initState();

    _selectedStatuses = widget.order.statusTimeline
        .map((e) => e['status'] as String)
        .toSet();
  }

  Future<void> _saveOrderStatus() async {
    final docRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.order.id);

    final doc = await docRef.get();

    if (!doc.exists) return;

    List<dynamic> timeline = doc.data()?['statusTimeline'] ?? [];

    final existingStatuses = timeline.map((e) => e['status'] as String).toSet();

    final newStatuses = _selectedStatuses.difference(existingStatuses);

    for (String status in newStatuses) {
      timeline.add({'status': status, 'time': Timestamp.now()});
    }

    await docRef.update({
      'statusTimeline': timeline,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await context.read<AdminDashboardProvider>().refreshDashboard();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final OrderModel order = widget.order;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).colorScheme.onInverseSurface,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        title: Text(
          AppConstants.updtOrder,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _orderDetails(order),
    );
  }

  Widget _orderDetails(OrderModel order) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      shrinkWrap: true,
      children: [
        _sectionTitle(AppConstants.orderStatus),
        _statusSection(order.statusTimeline),
        const SizedBox(height: 24),
        _sectionTitle(AppConstants.orderDetails),
        _greyCard(
          children: [
            _row(AppConstants.orderNo, order.orderNumber.toString()),
            _row(AppConstants.orderID, order.id),
            _row(AppConstants.userID, order.userId),
          ],
        ),

        const SizedBox(height: 24),
        _sectionTitle(AppConstants.orderSummary),
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
              AppConstants.subtotal,
              AppConstants.dolrAmount(order.pricing['subtotal']),
            ),
            _row(
              AppConstants.discount,
              "-${AppConstants.dolrAmount(order.pricing['discount'])}",
            ),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              AppConstants.total,
              AppConstants.dolrAmount(order.pricing['total']),
              isBold: true,
            ),
          ],
        ),
        const SizedBox(height: 24),

        _sectionTitle(AppConstants.paymentDetails),
        _greyCard(
          children: [_row("Method", "${order.paymentMethod}", isBold: true)],
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

  Widget _statusSection(List<Map<String, dynamic>> timeline) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orderSteps.length,
            itemBuilder: (context, index) {
              final status = _orderSteps[index];
              final isChecked = _selectedStatuses.contains(status);

              String formattedStatus = status
                  .replaceAll('_', ' ')
                  .toLowerCase()
                  .split(' ')
                  .map((w) => w[0].toUpperCase() + w.substring(1))
                  .join(' ');

              return CheckboxListTile(
                value: isChecked,
                // enabled: !isChecked,
                dense: true, // reduces vertical height
                visualDensity: const VisualDensity(vertical: -4),
                activeColor: Theme.of(context).colorScheme.onSecondary,
                side: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary,
                  width: 2,
                ),
                title: Text(
                  formattedStatus,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
              );
            },
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _saveOrderStatus,
              child: Text(
                AppConstants.updtOrderStatus,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
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
