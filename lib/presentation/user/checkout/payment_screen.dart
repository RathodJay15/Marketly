import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/services/razorpay_services.dart';
import 'package:marketly/presentation/user/orders/my_orders_screen.dart';
import 'package:marketly/presentation/widgets/marketly_dialog.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/navigation_provider.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final VoidCallback onBack;
  const PaymentScreen({super.key, required this.onBack});

  @override
  State<StatefulWidget> createState() => _paymentScreenState();
}

class _paymentScreenState extends State<PaymentScreen> {
  String _paymentMethod = 'Cash on Delivery';

  late RazorpayServices razorpayService;

  @override
  void initState() {
    super.initState();

    razorpayService = RazorpayServices();

    razorpayService.initialize(
      onSuccess: _handlePaymentSuccess,
      onFailur: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final orderProvider = context.read<OrderProvider>();

    orderProvider.setRazorpayPayment(
      orderId: response.orderId ?? '',
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
    );

    _placeOrder();
    debugPrint(
      "-----------------------Payment Success : ${response.paymentId}",
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("-----------------------Payment Failur : ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("-----------------------Wallet Name : ${response.walletName}");
  }

  Future<void> _placeOrder() async {
    final orderProvider = context.read<OrderProvider>();
    final cartProvider = context.read<CartProvider>();
    final navigationProvider = context.read<NavigationProvider>();

    orderProvider.setPaymentMethod(_paymentMethod);

    // Place order via PROVIDER
    await orderProvider.placeOrder(
      discount: cartProvider.totalDiscount,
      grandTotal: cartProvider.finalTotal,
      subTotal: cartProvider.subTotal,
    );

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

  @override
  void dispose() {
    razorpayService.dispose();
    super.dispose();
  }

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
                width: 120,
                child: ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.onInverseSurface,
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
                  onPressed: () async {
                    final orderProvider = context.read<OrderProvider>();
                    if (_paymentMethod != 'Cash on Delivery') {
                      razorpayService.openCheckOut(
                        amount: orderProvider.order!.pricing["total"],
                        description: AppConstants.orderOf(
                          orderProvider.order!.items.length,
                        ),
                        email: orderProvider.order!.userInfo['email'],
                        name: orderProvider.order!.userInfo['name'],
                        phoneNo: orderProvider.order!.userInfo['phone'],
                        paymentMethod: _paymentMethod,
                      );
                    } else {
                      final shouldOrder = await MarketlyDialog.showMyDialog(
                        context: context,
                        title: AppConstants.confirmCod,
                        content: AppConstants.codOrderMsg,
                        actionY: AppConstants.placeOrder,
                        actionN: AppConstants.cancel,
                      );

                      if (shouldOrder == true) {
                        _placeOrder();
                      }
                    }
                  },
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
            Divider(color: Theme.of(context).colorScheme.onPrimary),
            _row(
              AppConstants.total,
              AppConstants.inrAmount(order.pricing['total']),
              isBold: true,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _sectionTitle(AppConstants.paymentMethod),
        _paymentMethods(order.pricing['total']),
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

  Widget _paymentMethods(double total) {
    return RadioGroup<String>(
      groupValue: _paymentMethod,
      onChanged: (value) {
        setState(() {
          _paymentMethod = value!;
        });
      },
      child: _greyCard(
        children: [
          _radioTile(
            AppConstants.upi,
            AppConstants.upi,
            enabled: total <= 100000,
            message: AppConstants.upiUnavailable,
          ),
          _radioTile(AppConstants.card, AppConstants.card),
          _radioTile(AppConstants.netBanking, AppConstants.netBanking),
          _radioTile(AppConstants.cod, AppConstants.cod),
        ],
      ),
    );
  }

  Widget _radioTile(
    String value,
    String label, {
    bool enabled = true,
    String? message,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<String>(
          value: value,
          enabled: enabled,
          fillColor: WidgetStateProperty.resolveWith(
            (states) => Theme.of(context).colorScheme.onPrimary,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? Theme.of(context).colorScheme.onInverseSurface
                  : Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        if (!enabled && message != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
