import 'package:equatable/equatable.dart';
import 'package:rmss/core/models/payment_model.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {}

class AddPayment extends PaymentEvent {
  final PaymentModel item;
  AddPayment({required this.item});

  @override
  List<Object?> get props => [item];
}

class UpdatePayment extends PaymentEvent {
  final PaymentModel item;
  UpdatePayment({required this.item});

  @override
  List<Object?> get props => [item];
}

class DeletePayment extends PaymentEvent {
  final PaymentModel item;
  DeletePayment({required this.item});

  @override
  List<Object?> get props => [item];
}
