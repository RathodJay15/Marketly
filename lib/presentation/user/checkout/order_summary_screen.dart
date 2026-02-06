import 'package:flutter/material.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class OrderSummaryScreen extends StatefulWidget {
  final VoidCallback onNext;
  const OrderSummaryScreen({super.key, required this.onNext});

  @override
  State<StatefulWidget> createState() => _orderSummaryScreenState();
}

class _orderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return isLandscape
            ? _landsacpeView(context, cartProvider)
            : _protrateView(context, cartProvider, widget.onNext);
      },
    );
  }
  // ---------------------------------------------------------------------------
  // Lanscape View
  // ---------------------------------------------------------------------------

  Widget _landsacpeView(BuildContext context, CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
  }

  // ---------------------------------------------------------------------------
  // Protrate View
  // ---------------------------------------------------------------------------

  Widget _protrateView(
    BuildContext context,
    CartProvider cartProvider,
    VoidCallback onNext,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: onNext,
                child: const Text("Next"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
