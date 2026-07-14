import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

class CartState extends Equatable {
  final List<OrderItemModel> items;

  const CartState({required this.items});

  double get totalPrice {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  @override
  List<Object?> get props => [items];
}
