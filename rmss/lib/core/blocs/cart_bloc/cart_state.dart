import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartUpdated extends CartState {
  final List<OrderItemModel> items;

  CartUpdated({required this.items});

  double get totalPrice {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  @override
  List<Object?> get props => [items];
}
