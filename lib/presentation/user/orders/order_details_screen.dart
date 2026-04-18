import 'package:another_stepper/another_stepper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:iconoir_icons/iconoir_icons.dart';
import 'package:marketly/core/constants/app_constants.dart';
import 'package:marketly/core/constants/app_helpers.dart';
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
        _error = AppConstants.orderNotFound;
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
            icon: Iconoir(IconoirIcons.navArrowLeft),
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
                AppConstants.inrAmount(item['finalPrice']),
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
            if (order.pricing['couponDiscount'] != null)
              _row(
                AppConstants.couponDiscount,
                "-${AppConstants.inrAmount(order.pricing['couponDiscount'])}",
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
          children: [
            _row(AppConstants.method, order.paymentMethod, isBold: true),
          ],
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

  Widget _orderStatusTimeline(BuildContext context, OrderModel order) {
    const List<String> orderSteps = [
      'ORDER_PLACED',
      'ORDER_CONFIRMED',
      'ORDER_SHIPPED',
      'OUT_FOR_DELIVERY',
      'ORDER_DELIVERED',
    ];

    final completedStatuses = {
      for (var e in order.statusTimeline) e['status']: e['time'] as Timestamp,
    };

    // 🔥 current step = number of completed statuses - 1
    int currentStep = completedStatuses.length - 1;

    String formatStatus(String status) {
      return status
          .replaceAll('_', ' ')
          .toLowerCase()
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
    }

    return AnotherStepper(
      stepperDirection: Axis.horizontal,
      activeIndex: currentStep,
      barThickness: 2,
      verticalGap: 15,
      activeBarColor: Theme.of(context).colorScheme.onSecondary,
      inActiveBarColor: Theme.of(context).colorScheme.onInverseSurface,
      iconWidth: 26,
      iconHeight: 26,

      stepperList: List.generate(orderSteps.length, (index) {
        final status = orderSteps[index];
        final isCompleted = completedStatuses.containsKey(status);
        final time = completedStatuses[status];

        return StepperData(
          title: StepperText(
            "${formatStatus(status)}${time != null ? "\n${AppHelpers.formatedDate(time)}" : ""}",
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
              color: isCompleted
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),

          iconWidget: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onInverseSurface,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
