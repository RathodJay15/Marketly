import 'cart_item_model.dart';

class CartModel {
  final List<CartItemModel> items;

  CartModel(this.items);

  bool get isEmpty => items.isEmpty;

  int get totalProducts => items.length;

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  // Total amount BEFORE discount
  double get subTotal =>
      items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  // Total amount AFTER discount
  double get totalAmount => items.fold(0.0, (sum, item) {
    final itemTotal = item.price * item.quantity;
    final discount = itemTotal * item.discountPercentage / 100;
    return sum + (itemTotal - discount);
  });

  // Effective discount percentage over entire cart
  double get totalDiscountPercentage {
    if (subTotal == 0) return 0;

    final discountAmount = subTotal - totalAmount;
    return (discountAmount / subTotal) * 100;
  }
}
