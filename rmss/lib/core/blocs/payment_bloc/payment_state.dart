import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/payment_model.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentsLoading extends PaymentState {}

class PaymentsLoaded extends PaymentState {
  final List<PaymentModel> items;

  PaymentsLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});

  @override
  List<Object?> get props => [message];
}
