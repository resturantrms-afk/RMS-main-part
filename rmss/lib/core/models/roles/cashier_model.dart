import 'package:rmss/core/models/user_model.dart';

class CashierModel {
  final UserModel user;
  final int totalOrdersProcessed;
  final double totalRevenueCollected;

  CashierModel({
    required this.user,
    required this.totalOrdersProcessed,
    required this.totalRevenueCollected,
  });

  factory CashierModel.fromJson(UserModel user, Map<String, dynamic> json) {
    return CashierModel(
      user: user,
      totalOrdersProcessed: json['totalOrdersProcessed'] ?? 0,
      totalRevenueCollected: (json['totalRevenueCollected'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrdersProcessed': totalOrdersProcessed,
      'totalRevenueCollected': totalRevenueCollected,
    };
  }
}
