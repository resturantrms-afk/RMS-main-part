import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrder extends OrderEvent {}

class AddOrder extends OrderEvent {
  final OrderModel item;
  AddOrder({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdateOrder extends OrderEvent {
  final OrderModel item;
  UpdateOrder({required this.item});

  @override
  List<Object?> get props => [item];
}

class DeleteOrder extends OrderEvent {
  final OrderModel item;
  DeleteOrder({required this.item});

  @override
  List<Object?> get props => [item];
}
