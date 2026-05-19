import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/order_model.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderModel> items;

  OrderLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class OrderError extends OrderState {
  final String message;
  OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
