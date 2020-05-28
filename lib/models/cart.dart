import 'package:flutter/foundation.dart';

import 'catalog.dart';

@immutable
class CartState {
  CartState({this.items});

  // List of items in the cart.
  final List<Item> items;

  /// The current total price of all items.
  int get totalPrice =>
      items.fold(0, (total, current) => total + current.price);

  /// Adds [item] to cart.
  /// methods can be static
  static CartState add(CartState currentState, Item item) {
    return CartState(items: [...currentState.items, item]);
  }
}
