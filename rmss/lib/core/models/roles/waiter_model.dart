import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmss/core/models/user_model.dart';

enum WaiterActionType { served, cleaned, ordered }

class WaiterAction {
  final String tableId;
  final WaiterActionType actionType;
  final Timestamp date;
  final String? orderId; // Optional, used when action is 'ordered'

  WaiterAction({
    required this.tableId,
    required this.actionType,
    required this.date,
    this.orderId,
  });

  factory WaiterAction.fromJson(Map<String, dynamic> json) {
    return WaiterAction(
      tableId: json['tableId'] ?? '',
      actionType: WaiterActionType.values.firstWhere(
        (e) => e.name == (json['actionType'] ?? 'served'),
        orElse: () => WaiterActionType.served,
      ),
      date: json['date'] ?? Timestamp.now(),
      orderId: json['orderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'actionType': actionType.name,
      'date': date,
      'orderId': orderId,
    };
  }
}

class WaiterModel {
  final UserModel user;
  final List<WaiterAction> actions;

  WaiterModel({
    required this.user,
    required this.actions,
  });

  factory WaiterModel.fromJson(UserModel user, Map<String, dynamic> json) {
    return WaiterModel(
      user: user,
      actions: (json['actions'] as List<dynamic>? ?? [])
          .map((e) => WaiterAction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'actions': actions.map((e) => e.toJson()).toList(),
    };
  }
}
