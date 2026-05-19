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
