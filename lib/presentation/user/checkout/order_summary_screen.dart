import 'package:flutter/material.dart';
import 'package:marketly/data/models/cart_item_model.dart';
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
      mainAxisAlignment: MainAxisAlignment.start,
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
        _productListScetion(context, cartProvider),
        _totalSection(20, context, cartProvider),
        _bottomButtoms(onNext),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Product List Section
  // ---------------------------------------------------------------------------

  Widget _productListScetion(BuildContext context, CartProvider cartProvider) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.separated(
          itemCount: cartProvider.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = cartProvider.items[index];
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
                  _priceRow("Base price", item.price),
                  if (item.discountedTotal > 0)
                    _priceRow(
                      "Discount (${item.discountPercentage} % off)",
                      -(item.price - item.discountedTotal),
                      isDiscount: true,
                    ),
                  Divider(color: Theme.of(context).colorScheme.onPrimary),
                  _priceRow("Item total", item.discountedTotal, isBold: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _collapsedHeader(BuildContext context, CartItemModel item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.thumbnail,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Qty: ${item.quantity}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Text(
          "\$${item.discountedTotal.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String label,
    double value, {
    bool isBold = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isDiscount
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          Text(
            "${value < 0 ? "-" : ""}\$${value.abs().toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: isDiscount
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Total Section
  // ---------------------------------------------------------------------------

  Widget _totalSection(
    double paddingH,
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH),
      child: Column(
        children: [
          Divider(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            thickness: 2,
            radius: BorderRadius.circular(2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '\$ ${cartProvider.subTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discount (${cartProvider.totalDiscountPercentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '- ${cartProvider.totalDiscount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            thickness: 3,
            radius: BorderRadius.circular(2),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '\$ ${cartProvider.finalTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //----------------------------------------------------------------------------
  // Bottom Buttom
  //----------------------------------------------------------------------------

  Widget _bottomButtoms(VoidCallback onNext) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                minimumSize: const Size(double.infinity, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                "Next",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
