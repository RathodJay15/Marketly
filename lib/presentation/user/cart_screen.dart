import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:marketly/presentation/user/checkout/checkout_flow_screen.dart';
import 'package:marketly/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<StatefulWidget> createState() => _cartScreenState();
}

class _cartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        if (cartProvider.items.isEmpty) {
          return _emptyCartView(context, cartProvider);
        }
        return isLandscape
            ? _landsacpeView(context, cartProvider)
            : _protrateView(context, cartProvider);
      },
    );
  }
  // ---------------------------------------------------------------------------
  // Empty Cart View
  // ---------------------------------------------------------------------------

  Widget _emptyCartView(BuildContext context, CartProvider cartProvider) {
    return Column(
      children: [
        _headerSection(10, context, cartProvider),
        Expanded(
          child: Center(
            child: Text(
              'No Item in the cart, Cart is Empty !!',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Lanscape View
  // ---------------------------------------------------------------------------

  Widget _landsacpeView(BuildContext context, CartProvider cartProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _headerSection(0, context, cartProvider),
                Expanded(child: _cartPoductList(context, cartProvider)),
              ],
            ),
          ),
        ),
        SizedBox(width: 350, child: _cartSummary(10, context, cartProvider)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Protrate View
  // ---------------------------------------------------------------------------

  Widget _protrateView(BuildContext context, CartProvider cartProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _headerSection(10, context, cartProvider),
        _cartPoductList(context, cartProvider),
        _cartSummary(20, context, cartProvider),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header Section
  // ---------------------------------------------------------------------------

  Widget _headerSection(
    double paddingV,
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: paddingV),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cart',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onInverseSurface,
            ),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  title: Text(
                    'Empty cart?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to remove all items from your cart? '
                    'This action can’t be undone.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Yes, empty cart',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                cartProvider.clearCart();
              }
            },
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cart List Section
  // ---------------------------------------------------------------------------

  Widget _cartPoductList(BuildContext context, CartProvider cartProvider) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: cartProvider.items.length,
        itemBuilder: (context, index) {
          final item = cartProvider.items[index];
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: CachedNetworkImage(
                    imageUrl: item.thumbnail,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => Container(
                      color: Theme.of(context).colorScheme.onPrimary,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$${item.price} x ${item.quantity}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onInverseSurface,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${item.discountPercentage}% off ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          cartProvider.updateQuantity(
                            item.id,
                            item.quantity + 1,
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.add_rounded),
                        iconSize: 25,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      Text(
                        '${item.quantity}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onInverseSurface,
                          fontSize: 15,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          cartProvider.updateQuantity(
                            item.id,
                            item.quantity - 1,
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.remove_rounded),
                        iconSize: 25,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cart Summary Section
  // ---------------------------------------------------------------------------

  Widget _cartSummary(
    double paddingH,
    BuildContext context,
    CartProvider cartProvider,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Products: ${cartProvider.totalProducts}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 18,
                ),
              ),
              Text(
                'Total of Quantity: ${cartProvider.totalQuantity}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 18,
                ),
              ),
            ],
          ),
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
          SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                if (!cartProvider.isCartLocked) cartProvider.lockCart();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CheckoutFlowScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
                minimumSize: const Size(double.infinity, 50.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Go to Check Out!',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
