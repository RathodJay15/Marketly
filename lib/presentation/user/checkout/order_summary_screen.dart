import 'package:flutter/material.dart';
import 'package:marketly/core/constants/app_constansts.dart';
import 'package:marketly/data/models/cart_item_model.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:marketly/providers/order_provider.dart';
import 'package:marketly/providers/user_provider.dart';
import 'package:provider/provider.dart';

class OrderSummaryScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onCancel;
  const OrderSummaryScreen({
    super.key,
    required this.onNext,
    required this.onCancel,
  });

  @override
  State<StatefulWidget> createState() => _orderSummaryScreenState();
}

class _orderSummaryScreenState extends State<OrderSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return PopScope(
      canPop: false,
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return isLandscape
              ? _landsacpeView(
                  context,
                  cartProvider,
                  widget.onNext,
                  widget.onCancel,
                )
              : _protrateView(
                  context,
                  cartProvider,
                  widget.onNext,
                  widget.onCancel,
                );
        },
      ),
    );
  }
  // ---------------------------------------------------------------------------
  // Lanscape View
  // ---------------------------------------------------------------------------

  Widget _landsacpeView(
    BuildContext context,
    CartProvider cartProvider,
    VoidCallback onNext,
    VoidCallback onCancel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _productListScetion(10, context, cartProvider),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 350,
                child: _totalSection(10, context, cartProvider),
              ),
              _bottomButtoms(onNext, onCancel),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Protrate View
  // ---------------------------------------------------------------------------

  Widget _protrateView(
    BuildContext context,
    CartProvider cartProvider,
    VoidCallback onNext,
    VoidCallback onCancel,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _productListScetion(20, context, cartProvider)),
        _totalSection(20, context, cartProvider),
        _bottomButtoms(onNext, onCancel),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Product List Section
  // ---------------------------------------------------------------------------

  Widget _productListScetion(
    double paddingH,
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH),
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
                _priceRow(AppConstants.subtotal, item.total),
                if (item.discountedTotal > 0)
                  _priceRow(
                    '${AppConstants.discount} ${AppConstants.discountOff(item.discountPercentage)}',
                    -(item.total - item.discountedTotal),
                    isDiscount: true,
                  ),
                Divider(color: Theme.of(context).colorScheme.onPrimary),
                _priceRow(
                  AppConstants.itemFinalTot,
                  item.discountedTotal,
                  isBold: true,
                ),
              ],
            ),
          );
        },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                "${AppConstants.basePrice}: ${AppConstants.dolrAmount(item.price)}",
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Text(
                "${AppConstants.qty}: ${item.quantity}",
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
          AppConstants.dolrAmount(item.discountedTotal),
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
            "${value < 0 ? "-" : ""}\$${AppConstants.dolrAmount(value.abs())}",
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
                AppConstants.subtotal,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 5),
              Text(
                AppConstants.dolrAmount(cartProvider.subTotal),
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
                '${AppConstants.discount} (${AppConstants.discountOff(cartProvider.totalDiscountPercentage)})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 5),
              Text(
                '- ${AppConstants.dolrAmount(cartProvider.totalDiscount)}',
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
                AppConstants.total,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              SizedBox(width: 5),
              Text(
                AppConstants.dolrAmount(cartProvider.finalTotal),
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

  Widget _bottomButtoms(VoidCallback onNext, VoidCallback onCancel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () => onCancel(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
                minimumSize: const Size(double.infinity, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                AppConstants.cancel,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {
                _setOrderFromCart(context);
                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                minimumSize: const Size(double.infinity, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                AppConstants.next,
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

  void _setOrderFromCart(BuildContext context) {
    final cartProvider = context.read<CartProvider>();
    final userProvider = context.read<UserProvider>();
    final orderProvider = context.read<OrderProvider>();

    final user = userProvider.user;
    if (user == null) return;

    // Init order only once
    if (orderProvider.order == null) {
      orderProvider.initOrder(
        userId: user.uid,
        userInfo: {"name": user.name, "email": user.email, "phone": user.phone},
      );
    }

    // Convert cart → order items
    final items = cartProvider.items.map((item) {
      return {
        "productId": item.id,
        "title": item.title,
        "price": item.price,
        "quantity": item.quantity,
        "discount": item.discountPercentage,
        "finalPrice": item.discountedTotal,
        "image": item.thumbnail,
      };
    }).toList();

    // Pricing
    final pricing = {
      "subtotal": cartProvider.subTotal,
      "discount": cartProvider.totalDiscount,
      "discountPercentage": cartProvider.totalDiscountPercentage,
      "total": cartProvider.finalTotal,
    };

    orderProvider.setItems(items);
    orderProvider.setPricing(pricing);
  }
}
