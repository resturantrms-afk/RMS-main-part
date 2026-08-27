import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final OrderItemModel item;

  AddToCart({required this.item});

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final OrderItemModel item;

  RemoveFromCart({required this.item});

  @override
  List<Object?> get props => [item];
}

class ClearCart extends CartEvent {}

class UpdateCartItemQuantity extends CartEvent {
  final String menuItemId;
  final int delta; // +1 or -1

  UpdateCartItemQuantity({required this.menuItemId, required this.delta});

  @override
  List<Object?> get props => [menuItemId, delta];
}

class UpdateCartItemNote extends CartEvent {
  final String menuItemId;
  final String newNotes;

  UpdateCartItemNote({required this.menuItemId, required this.newNotes});

  @override
  List<Object?> get props => [menuItemId, newNotes];
}

class LoadGlobalTax extends CartEvent {}
