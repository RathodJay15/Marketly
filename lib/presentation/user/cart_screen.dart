import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_headerSection(), _cartPoductList(), _cartSummary()],
    );
  }

  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
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
            onPressed: () {},
            color: Theme.of(context).colorScheme.onSecondaryContainer,
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

  Widget _cartPoductList() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: .30),
          borderRadius: BorderRadius.circular(30),
        ),

        child: ListView.builder(
          itemCount: 10,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item Title'),
              subtitle: Text('Item SubTitle'),
            );
          },
        ),
      ),
    );
  }

  Widget _cartSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '7 Items',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 20,
                  ),
                ),
              ),
              Text(
                '\$ 99,999',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: Theme.of(context).colorScheme.onPrimary,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                '\$ 88,888',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontSize: 25,
                ),
              ),
            ],
          ),
          ElevatedButton(onPressed: () {}, child: Text('Go to Check Out')),
        ],
      ),
    );
  }
}
