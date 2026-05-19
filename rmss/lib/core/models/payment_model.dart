import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PaymentMethod { cash, zaad }

class PaymentModel extends Equatable {
  final String id;
  final String orderId;
  final Map<String, dynamic> processedBy; // e.g. {cashier : id} or {admin : id}
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final Timestamp createdAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.processedBy,
    required this.paymentMethod,
    required this.amountPaid,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, String documentId) {
    return PaymentModel(
      id: documentId,
      orderId: json['orderId'] ?? '',
      processedBy: json['processedBy'] as Map<String, dynamic>? ?? {},
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['paymentMethod'] ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'processedBy': processedBy,
      'paymentMethod': paymentMethod.name,
      'amountPaid': amountPaid,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    processedBy,
    paymentMethod,
    amountPaid,
    createdAt,
  ];
}
