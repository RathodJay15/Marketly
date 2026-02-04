import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;

  CartModel(this.items);

  bool get isEmpty => items.isEmpty;

  int get totalProducts => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => items.fold(0.0, (sum, item) {
    final itemTotal = item.price * item.quantity;
    final discount = itemTotal * item.discountPercentage / 100;
    return sum + (itemTotal - discount);
  });
}
