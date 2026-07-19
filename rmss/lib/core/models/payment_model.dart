import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PaymentMethod { cash, zaad, edahab }

enum PaymentStatus { completed, voided }

class PaymentModel extends Equatable {
  final String id;
  final String orderId;
  final Map<String, dynamic> processedBy;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final PaymentStatus status;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.processedBy,
    required this.paymentMethod,
    required this.amountPaid,
    this.status = PaymentStatus.completed,
    required this.createdAt,
    required this.updatedAt,
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
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'completed'),
        orElse: () => PaymentStatus.completed,
      ),
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? json['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'processedBy': processedBy,
      'paymentMethod': paymentMethod.name,
      'amountPaid': amountPaid,
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? orderId,
    Map<String, dynamic>? processedBy,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    PaymentStatus? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      processedBy: processedBy ?? this.processedBy,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    processedBy,
    paymentMethod,
    amountPaid,
    status,
    createdAt,
    updatedAt,
  ];
}
