import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_event.dart';
import 'package:rmss/core/blocs/cart_bloc/cart_state.dart';
import 'package:rmss/core/models/order_model.dart';
import 'package:rmss/core/repositories/tax_history_repository.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final TaxHistoryRepository _taxHistoryRepository = TaxHistoryRepository();
  final List<OrderItemModel> _cartItems = [];
  final String tableId = 'unknown';
  final int tableNumber = 1;

  CartBloc() : super(const CartState(items: [])) {
    on<LoadGlobalTax>((event, emit) async {
      final tax = await _taxHistoryRepository.getGlobalTax();
      emit(state.copyWith(globalTaxPercent: tax));
    });

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
          imageUrl: existingItem.imageUrl,
        );
      } else {
        // if it is a new item, add it to the list
        final newItem = OrderItemModel(
          menuItemId: event.item.menuItemId,
          name: event.item.name,
          price: event.item.price,
          quantity: event.item.quantity,
          notes: event.item.notes,
          imageUrl: event.item.imageUrl,
        );
        _cartItems.add(newItem);
      }

      // emit the updated list
      emit(state.copyWith(items: List.from(_cartItems)));
    });
    on<RemoveFromCart>((event, emit) {
      _cartItems.removeWhere(
        (item) => item.menuItemId == event.item.menuItemId,
      );
      emit(state.copyWith(items: List.from(_cartItems)));
    });

    on<ClearCart>((event, emit) {
      _cartItems.clear();
      emit(state.copyWith(items: const []));
    });

    on<UpdateCartItemQuantity>((event, emit) {
      final index = _cartItems.indexWhere(
        (i) => i.menuItemId == event.menuItemId,
      );
      if (index < 0) return;

      final item = _cartItems[index];
      final newQty = item.quantity + event.delta;

      if (newQty <= 0) {
        // If quantity drops to 0 or below, remove the item entirely
        _cartItems.removeAt(index);
      } else {
        _cartItems[index] = OrderItemModel(
          menuItemId: item.menuItemId,
          name: item.name,
          price: item.price,
          quantity: newQty,
          notes: item.notes,
          imageUrl: item.imageUrl,
        );
      }
      emit(state.copyWith(items: List.from(_cartItems)));
    });

    on<UpdateCartItemNote>((event, emit) {
      final index = _cartItems.indexWhere(
        (i) => i.menuItemId == event.menuItemId,
      );
      if (index < 0) return;

      final item = _cartItems[index];
      
      _cartItems[index] = OrderItemModel(
        menuItemId: item.menuItemId,
        name: item.name,
        price: item.price,
        quantity: item.quantity,
        notes: event.newNotes,
        imageUrl: item.imageUrl,
      );
      
      emit(state.copyWith(items: List.from(_cartItems)));
    });

    // Add initial event after all handlers are registered
    add(LoadGlobalTax());
  }
}
