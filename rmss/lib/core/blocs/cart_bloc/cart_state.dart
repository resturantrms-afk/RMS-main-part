import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

class CartState extends Equatable {
  final List<OrderItemModel> items;
  final double globalTaxPercent;

  const CartState({required this.items, this.globalTaxPercent = 0.0});

  double get totalPrice {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }

  double get totalTax {
    return totalPrice * (globalTaxPercent / 100);
  }

  CartState copyWith({
    List<OrderItemModel>? items,
    double? globalTaxPercent,
  }) {
    return CartState(
      items: items ?? this.items,
      globalTaxPercent: globalTaxPercent ?? this.globalTaxPercent,
    );
  }

  @override
  List<Object?> get props => [items, globalTaxPercent];
}
