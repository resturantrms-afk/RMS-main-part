import 'package:rmss/core/models/user_model.dart';

class KitchenModel {
  final UserModel user;
  final int dishesPrepared;

  KitchenModel({
    required this.user,
    this.dishesPrepared = 0,
  });

  factory KitchenModel.fromJson(UserModel user, Map<String, dynamic> json) {
    return KitchenModel(
      user: user,
      dishesPrepared: json['dishesPrepared'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishesPrepared': dishesPrepared,
    };
  }
}

class AdminModel {
  final UserModel user;
  // Admin specific stats can be added here
  
  AdminModel({required this.user});
}
