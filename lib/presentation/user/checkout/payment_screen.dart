import 'package:flutter/material.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/data/services/order_service.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PaymentScreen({super.key, required this.onBack});

  @override
  State<StatefulWidget> createState() => _paymentScreenState();
}

class _paymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'cod';

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
              _actionButton(
                label: "Back",
                onTap: widget.onBack,
                bg: Theme.of(context).colorScheme.onSurface,
              ),
              _actionButton(
                label: "Place Order",
                onTap: _placeOrder,
                bg: Theme.of(context).colorScheme.onInverseSurface,
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
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle("Final Order Summary"),
        _greyCard(
          children: [
            ...order.items.map(
              (item) => _row(
                "${item['title']} x ${item['quantity']}",
                "₹${item['total']}",
              ),
            ),
            const Divider(color: Colors.white24),
            _row("Subtotal", "₹${order.pricing['subtotal']}"),
            _row("Discount", "-₹${order.pricing['discount']}"),
            _row("Total", "₹${order.pricing['total']}", isBold: true),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle("User Details"),
        _greyCard(
          children: [
            _row("Name", order.userInfo['name']),
            _row("Email", order.userInfo['email']),
            _row("Phone", order.userInfo['phone']),
            const Divider(color: Colors.white24),
            _row("Address", order.address['address']),
            _row("City", order.address['city']),
            _row("State", order.address['state']),
            _row("Country", order.address['country']),
            _row("Pincode", order.address['pincode']),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle("Payment Method"),
        _greyCard(
          children: [
            _radioTile("upi", "UPI"),
            _radioTile("card", "Card"),
            _radioTile("cod", "Cash on Delivery"),
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
    final orderService = OrderService();

    final order = orderProvider.order;
    if (order == null) return;

    // set payment method
    orderProvider.setPaymentMethod(_paymentMethod);

    // save order
    await orderService.placeOrder(order);

    // clear states
    cartProvider.clearCart();
    orderProvider.clearOrder();

    // navigate to home
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
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
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
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
      activeColor: Colors.white,
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onChanged: (val) {
        setState(() => _paymentMethod = val!);
      },
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onTap,
    required Color bg,
  }) {
    return SizedBox(
      width: 140,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
