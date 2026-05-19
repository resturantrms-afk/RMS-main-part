import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/models/order_model.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final List<OrderItemModel> _cartItems = [];

  CartBloc() : super(CartUpdated(items: const [])) {
    on<AddToCart>((event, emit) {
      // check if the item is already in the cart
      final existingIndex = _cartItems.indexWhere(
        (i) => i.menuItemId == event.item.menuItemId,
      );

      if (existingIndex >= 0) {
        // if it is, increase the quantity
        final existingItem = _cartItems[existingIndex];
        _cartItems[existingIndex] = OrderItemModel(
          menuItemId: existingItem.menuItemId,
          name: existingItem.name,
          price: existingItem.price,
          quantity: existingItem.quantity + event.item.quantity,
          notes: '${existingItem.notes} \n ${event.item.notes}',
        );
      } else {
        // if it is a new item, add it to the list
        _cartItems.add(event.item);
      }

      // emit the updated list

      emit(CartUpdated(items: List.from(_cartItems)));
    });
    on<RemoveFromCart>((event, emit) {
      _cartItems.removeWhere(
        (item) => item.menuItemId == event.item.menuItemId,
      );
      emit(CartUpdated(items: List.from(_cartItems)));
    });

    on<ClearCart>((event, emit) {
      _cartItems.clear();
      emit(CartUpdated(items: const []));
    });
  }
}
