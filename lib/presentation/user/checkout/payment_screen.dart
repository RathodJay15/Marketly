import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PaymentScreen({super.key, required this.onBack});

  @override
  State<StatefulWidget> createState() => _paymentScreenState();
}

class _paymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _orderDetails()),

        /// Bottom buttons
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppConstants.back,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppConstants.placeOrder,
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Order details
  // ---------------------------------------------------------------------------

  Widget _orderDetails() {
    final order = context.watch<OrderProvider>().order;

    if (order == null ||
        order.address.isEmpty ||
        order.items.isEmpty ||
        order.pricing.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _sectionTitle(AppConstants.usrDetails),
        _greyCard(
          children: [
            _row(AppConstants.username, order.userInfo['name']),
            _row(AppConstants.email, order.userInfo['email']),
            _row(AppConstants.phone, order.userInfo['phone']),
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(AppConstants.adrs, order.address['address']),
            _row(AppConstants.ct, order.address['city']),
            _row(AppConstants.state, order.address['state']),
            _row(AppConstants.cntry, order.address['country']),
            _row(AppConstants.pincode, order.address['pincode']),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(AppConstants.fonalOrderSummary),
        _greyCard(
          children: [
            ...order.items.map(
              (item) => _row(
                "${item['title']} x ${item['quantity']}",
                AppConstants.dolrAmount(item['finalPrice']),
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

        _sectionTitle(AppConstants.paymentMethod),
        _greyCard(
          children: [
            _radioTile(AppConstants.upi, AppConstants.upi),
            _radioTile(AppConstants.card, AppConstants.card),
            _radioTile(AppConstants.cod, AppConstants.cod),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Place order logic
  // ---------------------------------------------------------------------------

  Future<void> _placeOrder() async {
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    final navigationProvider = context.read<NavigationProvider>();

    orderProvider.setPaymentMethod(_paymentMethod);

    // Place order via PROVIDER
    await orderProvider.placeOrder();

    // Clear states
    cartProvider.unlockCart();
    cartProvider.clearCart();
    orderProvider.clearOrder();

    // set NavBar index to Profile
    navigationProvider.setScreenIndex(3);

    // navigate to Profile/my order
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => MyOrdersScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppConstants.orderPlacedMsg,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
        duration: Duration(seconds: 2),
      ),
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

  Widget _radioTile(String value, String label) {
    return RadioListTile<String>(
      value: value,
      groupValue: _paymentMethod,
      fillColor: WidgetStateColor.resolveWith(
        (states) => Theme.of(context).colorScheme.onPrimary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      onChanged: (val) {
        setState(() => _paymentMethod = val!);
      },
    );
  }
}
